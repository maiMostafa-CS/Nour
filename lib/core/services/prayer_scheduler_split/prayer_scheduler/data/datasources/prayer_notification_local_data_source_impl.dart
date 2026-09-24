import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../features/adhan_settings/domain/repositories/ adhan_settings_repository.dart';
import '../../../../../../features/adhan_sound/data/datasources/adhan_local_data_source.dart';
import '../../../../../../features/iqama_setting/domain/repositories/iqama_settings_repository.dart';
import '../../../../../../features/prayer_times/data/datasources/prayer_local_data_source.dart';
import '../../../../../../features/prayer_times/domain/entities/PrayerDayScheduleEntity.dart';
import '../../../../alarm_cleanup/alarm_id_tracker.dart';
import '../../adhan_scheduler_service.dart';
import '../../config/prayer_scheduler_config.dart';
import '../../notifications/countdown_notification_service.dart';
import '../../scheduler/adhan_scheduler.dart';
import '../../scheduler/countdown_scheduler.dart';
import '../../scheduler/iqama_scheduler.dart';
import '../../services/adhan_asset_provider.dart';
import '../../utils/prayer_scheduler_ids.dart';
import 'prayer_notification_local_data_source.dart';

class PrayerNotificationLocalDataSourceImpl
    implements PrayerNotificationLocalDataSource {
  PrayerNotificationLocalDataSourceImpl({
    required PrayerLocalDataSource prayerCalculator,
    required AdhanSettingsRepository adhanSettingsRepository,
    required IqamaSettingsRepository iqamaSettingsRepository,
    required AdhanLocalDataSource adhanLocalDataSource,
    required AdhanAssetProvider adhanAssetProvider,
    AlarmIdTracker? alarmIdTracker,
  })  : _prayerCalculator = prayerCalculator,
        _adhanSettingsRepository = adhanSettingsRepository,
        _iqamaSettingsRepository = iqamaSettingsRepository,
        _adhanLocalDataSource = adhanLocalDataSource,
        _adhanAssetProvider = adhanAssetProvider,
        _alarmIdTracker = alarmIdTracker;

  final AdhanAssetProvider _adhanAssetProvider;
  final PrayerLocalDataSource _prayerCalculator;
  final AdhanSettingsRepository _adhanSettingsRepository;
  final IqamaSettingsRepository _iqamaSettingsRepository;
  final AdhanLocalDataSource _adhanLocalDataSource;
  final AlarmIdTracker? _alarmIdTracker;

  // ============================================================
  // BUILD SCHEDULE
  // ============================================================

  Future<List<DailyPrayerTimesEntity>> _buildSchedule({
    required double latitude,
    required double longitude,
    required int days,
  }) async {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final schedule = <DailyPrayerTimesEntity>[];

    for (var d = 0; d < days; d++) {
      final date = DateTime(
        today.year,
        today.month,
        today.day + d,
      );

      final model = _prayerCalculator.calculate(
        latitude: latitude,
        longitude: longitude,
        date: date,
      );

      schedule.add(
        DailyPrayerTimesEntity(
          date: date,
          fajr: model.fajr,
          sunrise: model.sunrise,
          dhuhr: model.dhuhr,
          asr: model.asr,
          maghrib: model.maghrib,
          isha: model.isha,
        ),
      );
    }

    return schedule;
  }

  // ============================================================
  // SCHEDULE FOR DAYS
  // ============================================================

  @override
  Future<void> scheduleForDays({
    required double latitude,
    required double longitude,
    required int days,
  }) async {
    prayerSchedulerLog(
      '════════════════════════════════════',
    );

    prayerSchedulerLog(
      '🚀 START scheduleForDays()',
    );

    prayerSchedulerLog(
      '📍 latitude = $latitude',
    );

    prayerSchedulerLog(
      '📍 longitude = $longitude',
    );

    prayerSchedulerLog(
      '📅 days = $days',
    );

    // ==========================================================
    // LOAD ADHAN SETTINGS
    // ==========================================================

    final adhanSettings =
    await _adhanSettingsRepository.getSettings();

    prayerSchedulerLog(
      '⚙️ ADHAN SETTINGS | '
          'Fajr=${adhanSettings.fajr} | '
          'Sunrise=${adhanSettings.sunrise} | '
          'Dhuhr=${adhanSettings.dhuhr} | '
          'Asr=${adhanSettings.asr} | '
          'Maghrib=${adhanSettings.maghrib} | '
          'Isha=${adhanSettings.isha}',
    );

    // ==========================================================
    // LOAD IQAMA SETTINGS
    // ==========================================================

    final iqamaSettings =
    await _iqamaSettingsRepository.getSettings();

    prayerSchedulerLog(
      '🕋 IQAMA SETTINGS | '
          'Fajr=${iqamaSettings.fajr} min | '
          'Dhuhr=${iqamaSettings.dhuhr} min | '
          'Asr=${iqamaSettings.asr} min | '
          'Maghrib=${iqamaSettings.maghrib} min | '
          'Isha=${iqamaSettings.isha} min',
    );

    // ==========================================================
    // LOAD ALL ADHAN RECITERS ONCE
    // ==========================================================

    final reciters =
    await _adhanLocalDataSource.getReciters();

    if (reciters.isEmpty) {
      throw Exception('No adhan reciters available');
    }

    final now = DateTime.now();

    final schedule = await _buildSchedule(
      latitude: latitude,
      longitude: longitude,
      days: days,
    );

    final windowEntries = <Map<String, String>>[];

    var scheduledAdhans = 0;
    var scheduledReminders = 0;
    var scheduledIqamas = 0;
    var scheduledCountdowns = 0;

    // ==========================================================
    // DAYS
    // ==========================================================

    for (var dayIndex = 0;
    dayIndex < schedule.length;
    dayIndex++) {
      final day = schedule[dayIndex];

      // ========================================================
      // PRAYER MOMENTS
      // ========================================================

      for (final moment in day.toMoments()) {
        // ======================================================
        // ADHAN SETTINGS
        // ======================================================

        final adhanEnabled =
        adhanSettings.isEnabled(moment.index);

        if (adhanEnabled) {
          prayerSchedulerLog(
            '🔊 Adhan ENABLED | '
                'prayer=${moment.name} | '
                'index=${moment.index}',
          );

          // ====================================================
          // DETERMINE PRAYER NAME
          // ====================================================

          final String? prayerName = switch (moment.index) {
            0 => 'fajr',
            2 => 'dhuhr',
            3 => 'asr',
            4 => 'maghrib',
            5 => 'isha',
            _ => null,
          };

          // ====================================================
          // GET SELECTED RECITER FOR THIS PRAYER
          // ====================================================

          if (prayerName == null) {
            prayerSchedulerLog(
              '⏭️ No Adhan reciter for '
                  'prayer=${moment.name} | '
                  'index=${moment.index}',
            );
          } else {
            final selectedAsset = await _adhanAssetProvider
                .getAssetForPrayer(prayerName);

            prayerSchedulerLog(
              '🎙️ SELECTED RECITER | '
                  'prayer=$prayerName | '
                  'asset=$selectedAsset',
            );

            // ==================================================
            // SCHEDULE ADHAN
            // ==================================================

            try {
              final adhanScheduled = await AdhanScheduler.schedule(
                dayIndex: dayIndex,
                moment: moment,
                adhanAssetPath: selectedAsset,
                enabled: adhanSettings.isEnabled(moment.index),
              );

              if (adhanScheduled) {
                scheduledAdhans++;

                // ─── سجّل معرّف الأذان ───
                final adhanId = PrayerSchedulerIds.adhan(
                  moment.time,
                  moment.index,
                );
                await _alarmIdTracker?.track(adhanId);
              }
            } catch (e, stackTrace) {
              prayerSchedulerLog(
                '❌ Adhan FAILED | '
                    'prayer=${moment.name} | '
                    'error=$e',
              );

              prayerSchedulerLog(
                'STACKTRACE: $stackTrace',
              );
            }
          }
        } else {
          prayerSchedulerLog(
            '🔇 Adhan DISABLED | '
                'prayer=${moment.name} | '
                'index=${moment.index}',
          );
        }

        // ======================================================
        // IQAMA
        // ======================================================

        if (adhanEnabled) {
          final iqamaMinutes = iqamaSettings.getMinutes(
            moment.index,
          );

          final iqamaTime = moment.time.add(
            Duration(
              minutes: iqamaMinutes,
            ),
          );

          prayerSchedulerLog(
            '🕋 IQAMA CALCULATED | '
                'prayer=${moment.name} | '
                'prayerTime=${moment.time} | '
                'delay=${iqamaMinutes}min | '
                'iqamaTime=$iqamaTime',
          );

          if (iqamaTime.isAfter(now)) {
            try {
              await IqamaScheduler.schedule(
                dayIndex: dayIndex,
                moment: moment,
                iqamaMinutes: iqamaMinutes,
              );

              scheduledIqamas++;

              // ─── سجّل معرّف الإقامة ───
              final iqamaId = PrayerSchedulerIds.iqama(
                moment.time,
                moment.index,
              );
              await _alarmIdTracker?.track(iqamaId);
            } catch (e, stackTrace) {
              prayerSchedulerLog(
                '❌ Iqama FAILED | '
                    'prayer=${moment.name} | '
                    'error=$e',
              );

              prayerSchedulerLog(
                'STACKTRACE: $stackTrace',
              );
            }
          } else {
            prayerSchedulerLog(
              '⏭️ IQAMA SKIPPED | '
                  'prayer=${moment.name} | '
                  'iqamaTime=$iqamaTime',
            );
          }
        } else {
          prayerSchedulerLog(
            '🔇 IQAMA DISABLED BECAUSE ADHAN IS DISABLED | '
                'prayer=${moment.name} | '
                'index=${moment.index}',
          );
        }

        // ======================================================
        // COUNTDOWN UPDATE
        // ======================================================

        if (moment.time.isAfter(now)) {
          try {
            await CountdownScheduler.schedule(
              moment: moment,
            );

            scheduledCountdowns++;

            // ─── سجّل معرّف العدّاد ───
            final countdownId = PrayerSchedulerIds.countdownUpdate(
              moment.time,
              moment.index,
            );
            await _alarmIdTracker?.track(countdownId);
          } catch (e, stackTrace) {
            prayerSchedulerLog(
              '❌ Countdown update FAILED | '
                  'prayer=${moment.name} | '
                  'error=$e',
            );

            prayerSchedulerLog(
              'STACKTRACE: $stackTrace',
            );
          }
        }

        // ======================================================
        // SAVE WINDOW
        // ======================================================

        windowEntries.add({
          'name': moment.name,
          'time': moment.time.toIso8601String(),
        });
      }
    }

    // ==========================================================
    // SAVE SCHEDULING DATA
    // ==========================================================

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      prayerScheduledDaysPrefsKey,
      days,
    );

    await prefs.setString(
      prayerScheduledFromPrefsKey,
      DateTime(
        now.year,
        now.month,
        now.day,
      ).toIso8601String(),
    );

    await prefs.setDouble(
      prayerScheduledLatitudePrefsKey,
      latitude,
    );

    await prefs.setDouble(
      prayerScheduledLongitudePrefsKey,
      longitude,
    );

    await prefs.setDouble(
      prayerLastLatitudePrefsKey,
      latitude,
    );

    await prefs.setDouble(
      prayerLastLongitudePrefsKey,
      longitude,
    );

    await prefs.setString(
      prayerNotificationWindowPrefsKey,
      jsonEncode(windowEntries),
    );

    // ==========================================================
    // INITIAL COUNTDOWN
    // ==========================================================

    try {
      await CountdownNotificationService
          .showNextPrayerCountdown();
    } catch (e, stackTrace) {
      prayerSchedulerLog(
        '❌ Initial countdown FAILED: $e',
      );

      prayerSchedulerLog(
        'STACKTRACE: $stackTrace',
      );
    }

    // ==========================================================
    // LOG RESULT
    // ==========================================================

    prayerSchedulerLog(
      '🎉 SCHEDULING FINISHED SUCCESSFULLY',
    );

    prayerSchedulerLog(
      '📅 Days = $days',
    );

    prayerSchedulerLog(
      '🕌 Adhans = $scheduledAdhans',
    );

    prayerSchedulerLog(
      '🔔 Reminders = $scheduledReminders',
    );

    prayerSchedulerLog(
      '🕋 Iqamas = $scheduledIqamas',
    );

    prayerSchedulerLog(
      '⏱️ Countdown updates = $scheduledCountdowns',
    );

    prayerSchedulerLog(
      '📦 Total entries = ${windowEntries.length}',
    );

    prayerSchedulerLog(
      '════════════════════════════════════',
    );
  }

  // ============================================================
  // ENSURE ROLLING WINDOW
  // ============================================================

  @override
  Future<void> ensureWindowScheduled({
    required double latitude,
    required double longitude,
    int days = kPrayerNotificationWindowDays,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final scheduledDays = prefs.getInt(
      prayerScheduledDaysPrefsKey,
    );

    final scheduledFromIso = prefs.getString(
      prayerScheduledFromPrefsKey,
    );

    bool needsReschedule = false;

    if (scheduledDays == null || scheduledFromIso == null) {
      prayerSchedulerLog(
        '📅 No previous schedule found → RESCHEDULE',
      );

      needsReschedule = true;
    } else {
      final scheduledFrom = DateTime.tryParse(scheduledFromIso);

      if (scheduledFrom == null) {
        prayerSchedulerLog(
          '❌ Invalid scheduledFrom → RESCHEDULE',
        );

        needsReschedule = true;
      } else {
        final today = DateTime.now();

        final startDate = DateTime(
          scheduledFrom.year,
          scheduledFrom.month,
          scheduledFrom.day,
        );

        final currentDate = DateTime(
          today.year,
          today.month,
          today.day,
        );

        final daysPassed =
            currentDate.difference(startDate).inDays;

        final daysRemaining = scheduledDays - daysPassed;

        prayerSchedulerLog(
          '📅 Scheduled=$scheduledDays | '
              'Passed=$daysPassed | '
              'Remaining=$daysRemaining',
        );

        if (daysRemaining <= 1) {
          prayerSchedulerLog(
            '🔄 Schedule window almost finished → RESCHEDULE',
          );

          needsReschedule = true;
        }
      }
    }

    if (!needsReschedule) {
      final locationChanged =
      await _hasScheduledLocationChanged(
        latitude: latitude,
        longitude: longitude,
      );

      if (locationChanged) {
        prayerSchedulerLog(
          '📍 Location changed → RESCHEDULE',
        );

        needsReschedule = true;
      }
    }

    if (!needsReschedule) {
      final alarmsExist = await _areFutureAdhansScheduled(
        latitude: latitude,
        longitude: longitude,
        days: days,
      );

      if (!alarmsExist) {
        prayerSchedulerLog(
          '❌ Future Adhan alarm missing → RESCHEDULE',
        );

        needsReschedule = true;
      }
    }

    if (needsReschedule) {
      await forceReschedule(
        latitude: latitude,
        longitude: longitude,
        days: days,
      );
    } else {
      prayerSchedulerLog(
        '✅ Existing $days-day schedule is still valid',
      );
    }
  }

  // ============================================================
  // CHECK LOCATION
  // ============================================================

  Future<bool> _hasScheduledLocationChanged({
    required double latitude,
    required double longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final scheduledLatitude = prefs.getDouble(
      prayerScheduledLatitudePrefsKey,
    );

    final scheduledLongitude = prefs.getDouble(
      prayerScheduledLongitudePrefsKey,
    );

    if (scheduledLatitude == null || scheduledLongitude == null) {
      prayerSchedulerLog(
        '📍 No scheduled location found → RESCHEDULE',
      );

      return true;
    }

    const tolerance = 0.0001;

    final latitudeChanged =
        (scheduledLatitude - latitude).abs() > tolerance;

    final longitudeChanged =
        (scheduledLongitude - longitude).abs() > tolerance;

    final changed = latitudeChanged || longitudeChanged;

    prayerSchedulerLog(
      '📍 SCHEDULED LOCATION CHECK | '
          'scheduled=($scheduledLatitude,$scheduledLongitude) | '
          'current=($latitude,$longitude) | '
          'changed=$changed',
    );

    return changed;
  }

  // ============================================================
  // CHECK FUTURE ADHANS
  // ============================================================

  Future<bool> _areFutureAdhansScheduled({
    required double latitude,
    required double longitude,
    required int days,
  }) async {
    final now = DateTime.now();

    final adhanSettings =
    await _adhanSettingsRepository.getSettings();

    final schedule = await _buildSchedule(
      latitude: latitude,
      longitude: longitude,
      days: days,
    );

    for (final day in schedule) {
      for (final moment in day.toMoments()) {
        if (!adhanSettings.isEnabled(moment.index)) {
          prayerSchedulerLog(
            '⏭️ Skip disabled Adhan check | '
                'prayer=${moment.name} | '
                'index=${moment.index}',
          );
          await Future.delayed(Duration.zero);
          continue;
        }

        if (!moment.time.isAfter(now)) {
          await Future.delayed(Duration.zero);
          continue;
        }

        final id = PrayerSchedulerIds.adhan(moment.time, moment.index);

        final alarm = await Alarm.getAlarm(id);

        await Future.delayed(Duration.zero);

        if (alarm == null) {
          prayerSchedulerLog(
            '❌ Missing future Adhan alarm | '
                'id=$id | prayer=${moment.name} | time=${moment.time}',
          );
          return false;
        }

        if (!alarm.dateTime.isAfter(now)) {
          prayerSchedulerLog(
            '❌ Adhan alarm is not future | '
                'id=$id | alarmTime=${alarm.dateTime}',
          );
          await Future.delayed(Duration.zero);
          return false;
        }
      }
    }

    prayerSchedulerLog(
      '✅ All ENABLED future Adhan alarms are scheduled',
    );

    return true;
  }

  // ============================================================
  // ALARM FIRED
  // ============================================================

  @override
  Future<void> onAlarmFired({
    required double latitude,
    required double longitude,
    int days = kPrayerNotificationWindowDays,
  }) async {
    prayerSchedulerLog(
      '🔔 onAlarmFired()',
    );

    prayerSchedulerLog(
      '📍 location=$latitude,$longitude',
    );

    await ensureWindowScheduled(
      latitude: latitude,
      longitude: longitude,
      days: days,
    );
  }

  // ============================================================
  // FORCE RESCHEDULE
  // ============================================================

  bool _isRescheduling = false;

  @override
  Future<void> forceReschedule({
    required double latitude,
    required double longitude,
    required int days,
  }) async {
    if (_isRescheduling) {
      prayerSchedulerLog(
        '⚠️ FORCE RESCHEDULE already running → SKIP',
      );
      return;
    }

    _isRescheduling = true;

    prayerSchedulerLog(
      '🚨 FORCE RESCHEDULE START',
    );

    prayerSchedulerLog(
      '📍 NEW LOCATION = $latitude, $longitude',
    );

    prayerSchedulerLog(
      '📅 DAYS = $days',
    );

    try {
      await cancelAll();

      prayerSchedulerLog(
        '🛑 OLD SCHEDULE CANCELLED',
      );

      await scheduleForDays(
        latitude: latitude,
        longitude: longitude,
        days: days,
      );

      prayerSchedulerLog(
        '✅ FORCE RESCHEDULE COMPLETED',
      );
    } catch (e, stackTrace) {
      prayerSchedulerLog(
        '❌ FORCE RESCHEDULE FAILED: $e',
      );

      prayerSchedulerLog(
        'STACKTRACE: $stackTrace',
      );

      rethrow;
    } finally {
      _isRescheduling = false;
    }
  }

  // ============================================================
  // CANCEL ALL
  // ============================================================

  @override
  Future<void> cancelAll() async {
    prayerSchedulerLog(
      '🛑 START cancelAll()',
    );

    final prefs = await SharedPreferences.getInstance();

    final previousDays =
        prefs.getInt(prayerScheduledDaysPrefsKey) ??
            kPrayerNotificationWindowDays;

    final scheduledFromIso = prefs.getString(
      prayerScheduledFromPrefsKey,
    );

    final scheduledFrom = scheduledFromIso != null
        ? DateTime.tryParse(scheduledFromIso)
        : null;

    final firstDay = scheduledFrom ?? DateTime.now();

    final daysToClear = previousDays.clamp(1, 60);

    var cancelled = 0;

    // ==========================================================
    // 🔥 SAFETY NET
    // ==========================================================

    try {
      final allAlarms = await Alarm.getAlarms();
      var safetyNetCancelled = 0;

      for (final alarm in allAlarms) {
        if (alarm.payload == 'adhan' ||
            alarm.payload == 'iqama' ||
            alarm.payload == 'reminder') {
          await Alarm.stop(alarm.id);
          safetyNetCancelled++;
        }
      }

      prayerSchedulerLog(
        '🔇 [Safety net] Cancelled $safetyNetCancelled alarms '
            'via getAlarms() (total=${allAlarms.length})',
      );
    } catch (e) {
      prayerSchedulerLog('⚠️ Safety net cancel error: $e');
    }

    // ==========================================================
    // 🧹 NEW: SWEEP ORPHAN ALARMS
    //
    // بيمسح المنبهات اليتيمة من النطاقات المعروفة
    // (اللي مش مسجلة في Alarm.getAlarms() ولا في AlarmIdTracker)
    // ==========================================================

    try {
      final swept = await _sweepOrphanAlarms();
      prayerSchedulerLog('🧹 [Sweep] Cancelled $swept orphan alarms');
    } catch (e) {
      prayerSchedulerLog('⚠️ Sweep orphan error: $e');
    }

    // ==========================================================
    // GET SCHEDULED LOCATION
    // ==========================================================

    final latitude = prefs.getDouble(
      prayerScheduledLatitudePrefsKey,
    );

    final longitude = prefs.getDouble(
      prayerScheduledLongitudePrefsKey,
    );

    // ==========================================================
    // CANCEL PRAYER ALARMS
    // ==========================================================

    if (latitude != null && longitude != null) {
      final schedule = await _buildSchedule(
        latitude: latitude,
        longitude: longitude,
        days: daysToClear,
      );

      for (final day in schedule) {
        for (final moment in day.toMoments()) {
          final adhanId = PrayerSchedulerIds.adhan(
            moment.time,
            moment.index,
          );

          final reminderId = PrayerSchedulerIds.reminder(
            moment.time,
            moment.index,
          );

          final iqamaId = PrayerSchedulerIds.iqama(
            moment.time,
            moment.index,
          );

          final countdownId = PrayerSchedulerIds.countdownUpdate(
            moment.time,
            moment.index,
          );

          try {
            await Alarm.stop(adhanId);
            await Alarm.stop(reminderId);
            await Alarm.stop(iqamaId);
            await AndroidAlarmManager.cancel(countdownId);

            cancelled++;

            prayerSchedulerLog(
              '🛑 CANCELLED | '
                  'prayer=${moment.name} | '
                  'time=${moment.time} | '
                  'adhanId=$adhanId | '
                  'iqamaId=$iqamaId',
            );
          } catch (e) {
            prayerSchedulerLog(
              '⚠️ Cancel error | '
                  'prayer=${moment.name} | '
                  'time=${moment.time} | '
                  'error=$e',
            );
          }
        }
      }
    } else {
      prayerSchedulerLog(
        '⚠️ Scheduled location missing | '
            'lat=$latitude | '
            'lng=$longitude',
      );

      for (var d = 0; d < daysToClear; d++) {
        final date = DateTime(
          firstDay.year,
          firstDay.month,
          firstDay.day + d,
        );

        for (var p = 0; p < 6; p++) {
          try {
            final countdownId = PrayerSchedulerIds.countdownUpdate(
              date,
              p,
            );

            await AndroidAlarmManager.cancel(countdownId);
          } catch (e) {
            prayerSchedulerLog(
              '⚠️ Countdown cancel error | '
                  'date=$date | '
                  'prayer=$p | '
                  'error=$e',
            );
          }
        }
      }
    }

    // ==========================================================
    // CANCEL COUNTDOWN NOTIFICATION
    // ==========================================================

    try {
      final notifications = FlutterLocalNotificationsPlugin();

      await notifications.cancel(
        id: countdownNotificationId,
      );
    } catch (e, stackTrace) {
      prayerSchedulerLog(
        '⚠️ Failed to cancel countdown notification',
      );

      prayerSchedulerLog('ERROR = $e');
      prayerSchedulerLog('STACKTRACE = $stackTrace');
    }

    // ==========================================================
    // CLEAR PREFS
    // ==========================================================

    await prefs.remove(prayerScheduledDaysPrefsKey);
    await prefs.remove(prayerScheduledFromPrefsKey);
    await prefs.remove(prayerNotificationWindowPrefsKey);

    // ==========================================================
    // ✅ CLEAR TRACKED ALARM IDs
    // ==========================================================

    await _alarmIdTracker?.clear();

    prayerSchedulerLog(
      '✅ cancelAll() completed | '
          'cancelled=$cancelled',
    );
  }

// ============================================================
// 🧹 SWEEP ORPHAN ALARMS
// ============================================================

  /// يمسح المنبهات اليتيمة من النطاقات المعروفة
  ///
  /// المنبهات اليتيمة هي اللي:
  /// - مش موجودة في `Alarm.getAlarms()`
  /// - مش مسجلة في `AlarmIdTracker`
  /// - لكن لسه مسجلة في نظام أندرويد
  ///
  /// الحل: نمر على كل الـ IDs في النطاقات المعروفة
  /// ونحاول نلغي كل واحد.
  Future<int> _sweepOrphanAlarms() async {
    // ⚠️ عدّل الأرقام دي حسب مشروعك
    const adhanBase = 124570;
    const iqamaBase = 324570;
    const countdownBase = 424570;
    const sweepRange = 200;

    final bases = [adhanBase, iqamaBase, countdownBase];

    var cancelled = 0;

    for (final base in bases) {
      for (int i = 0; i < sweepRange; i++) {
        final id = base + i;

        // 1️⃣ إلغاء من إضافة alarm
        try {
          await Alarm.stop(id);
          cancelled++;
        } catch (_) {
          // متوقع — المنبه مش موجود
        }

        // 2️⃣ إلغاء من إضافة android_alarm_manager_plus
        try {
          await AndroidAlarmManager.cancel(id);
        } catch (_) {
          // متوقع
        }
      }
    }

    return cancelled;
  }
  Future<(double, double)?> getScheduledLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(prayerScheduledLatitudePrefsKey);
    final lng = prefs.getDouble(prayerScheduledLongitudePrefsKey);
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }
}