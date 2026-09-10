import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../features/prayer_times/data/datasources/prayer_local_data_source.dart';
import '../../../../../../features/prayer_times/domain/entities/PrayerDayScheduleEntity.dart';
import '../../adhan_scheduler_service.dart';
import '../../config/prayer_scheduler_config.dart';
import '../../notifications/countdown_notification_service.dart';
import '../../scheduler/adhan_scheduler.dart';
import '../../scheduler/countdown_scheduler.dart';
import '../../scheduler/iqama_scheduler.dart';
import '../../utils/prayer_scheduler_ids.dart';
import 'prayer_notification_local_data_source.dart';

class PrayerNotificationLocalDataSourceImpl
    implements PrayerNotificationLocalDataSource {
  PrayerNotificationLocalDataSourceImpl({
    required PrayerLocalDataSource prayerCalculator,
  }) : _prayerCalculator = prayerCalculator;

  final PrayerLocalDataSource _prayerCalculator;

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
    prayerSchedulerLog('════════════════════════════════════');
    prayerSchedulerLog('🚀 START scheduleForDays()');
    prayerSchedulerLog('📍 latitude = $latitude');
    prayerSchedulerLog('📍 longitude = $longitude');
    prayerSchedulerLog('📅 days = $days');

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

    for (var dayIndex = 0; dayIndex < schedule.length; dayIndex++) {
      final day = schedule[dayIndex];

      for (final moment in day.toMoments()) {
        // ======================================================
        // ADHAN
        // ======================================================

        final adhanScheduled = await AdhanScheduler.schedule(
          dayIndex: dayIndex,
          moment: moment,
        );

        if (adhanScheduled) {
          scheduledAdhans++;
        }

        // ======================================================
        // IQAMA +15 MINUTES
        // ======================================================

        final iqamaTime = moment.time.add(
          const Duration(minutes: 15),
        );

        if (iqamaTime.isAfter(now)) {
          try {
            await IqamaScheduler.schedule(
              dayIndex: dayIndex,
              moment: moment,
            );

            scheduledIqamas++;
          } catch (e, stackTrace) {
            prayerSchedulerLog('❌ Iqama FAILED: $e');
            prayerSchedulerLog('STACKTRACE: $stackTrace');
          }
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
          } catch (e, stackTrace) {
            prayerSchedulerLog(
              '❌ Countdown update FAILED: $e',
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

    // الموقع الذي اتعملت عليه الجدولة
    await prefs.setDouble(
      prayerScheduledLatitudePrefsKey,
      latitude,
    );

    await prefs.setDouble(
      prayerScheduledLongitudePrefsKey,
      longitude,
    );

    // آخر موقع معروف
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
      await CountdownNotificationService.showNextPrayerCountdown();
    } catch (e, stackTrace) {
      prayerSchedulerLog(
        '❌ Initial countdown FAILED: $e',
      );

      prayerSchedulerLog(
        'STACKTRACE: $stackTrace',
      );
    }

    prayerSchedulerLog(
      '🎉 SCHEDULING FINISHED SUCCESSFULLY',
    );

    prayerSchedulerLog('📅 Days = $days');
    prayerSchedulerLog('🕌 Adhans = $scheduledAdhans');
    prayerSchedulerLog('🔔 Reminders = $scheduledReminders');
    prayerSchedulerLog('🕋 Iqamas = $scheduledIqamas');
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

    // ==========================================================
    // NO PREVIOUS SCHEDULE
    // ==========================================================

    if (scheduledDays == null || scheduledFromIso == null) {
      prayerSchedulerLog(
        '📅 No previous schedule found → RESCHEDULE',
      );

      needsReschedule = true;
    } else {
      final scheduledFrom = DateTime.tryParse(
        scheduledFromIso,
      );

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

        final daysPassed = currentDate
            .difference(startDate)
            .inDays;

        final daysRemaining =
            scheduledDays - daysPassed;

        prayerSchedulerLog(
          '📅 Scheduled=$scheduledDays | '
              'Passed=$daysPassed | '
              'Remaining=$daysRemaining',
        );

        // ======================================================
        // لو باقي يوم واحد أو أقل
        // ======================================================

        if (daysRemaining <= 1) {
          prayerSchedulerLog(
            '🔄 Schedule window almost finished → RESCHEDULE',
          );

          needsReschedule = true;
        }
      }
    }

    // ==========================================================
    // CHECK LOCATION
    // ==========================================================

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

    // ==========================================================
    // CHECK FUTURE ADHANS
    // ==========================================================

    if (!needsReschedule) {
      final alarmsExist =
      await _areFutureAdhansScheduled(
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

    // ==========================================================
    // RESCHEDULE
    // ==========================================================

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

    if (scheduledLatitude == null ||
        scheduledLongitude == null) {
      prayerSchedulerLog(
        '📍 No scheduled location found → RESCHEDULE',
      );

      return true;
    }

    const tolerance = 0.0001;

    final latitudeChanged =
        (scheduledLatitude - latitude).abs() >
            tolerance;

    final longitudeChanged =
        (scheduledLongitude - longitude).abs() >
            tolerance;

    final changed =
        latitudeChanged || longitudeChanged;

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

    final schedule = await _buildSchedule(
      latitude: latitude,
      longitude: longitude,
      days: days,
    );

    for (final day in schedule) {
      for (final moment in day.toMoments()) {
        // الصلاة انتهت
        if (!moment.time.isAfter(now)) {
          continue;
        }

        final id = PrayerSchedulerIds.adhan(
          moment.time,
          moment.index,
        );

        final alarm = await Alarm.getAlarm(id);

        if (alarm == null) {
          prayerSchedulerLog(
            '❌ Missing future Adhan alarm | '
                'id=$id | '
                'prayer=${moment.name} | '
                'time=${moment.time}',
          );

          return false;
        }

        if (!alarm.dateTime.isAfter(now)) {
          prayerSchedulerLog(
            '❌ Adhan alarm is not future | '
                'id=$id | '
                'alarmTime=${alarm.dateTime}',
          );

          return false;
        }
      }
    }

    prayerSchedulerLog(
      '✅ All future Adhan alarms are scheduled',
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

  @override
  Future<void> forceReschedule({
    required double latitude,
    required double longitude,
    required int days,
  }) async {
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
      // إلغاء الجدول القديم
      await cancelAll();

      prayerSchedulerLog(
        '🛑 OLD SCHEDULE CANCELLED',
      );

      // إنشاء جدول جديد
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
        prefs.getInt(
          prayerScheduledDaysPrefsKey,
        ) ??
            kPrayerNotificationWindowDays;

    final scheduledFromIso =
    prefs.getString(
      prayerScheduledFromPrefsKey,
    );

    final scheduledFrom =
    scheduledFromIso != null
        ? DateTime.tryParse(
      scheduledFromIso,
    )
        : null;

    final firstDay =
        scheduledFrom ??
            DateTime.now();

    final daysToClear =
    previousDays.clamp(1, 60);

    var cancelled = 0;

    for (var d = 0;
    d < daysToClear;
    d++) {
      final date = DateTime(
        firstDay.year,
        firstDay.month,
        firstDay.day + d,
      );

      for (var p = 0; p < 5; p++) {
        final adhanId =
        PrayerSchedulerIds.adhan(
          date,
          p,
        );

        final reminderId =
        PrayerSchedulerIds.reminder(
          date,
          p,
        );

        final iqamaId =
        PrayerSchedulerIds.iqama(
          date,
          p,
        );

        final countdownId =
        PrayerSchedulerIds.countdownUpdate(
          date,
          p,
        );

        try {
          await Alarm.stop(
            adhanId,
          );

          await Alarm.stop(
            reminderId,
          );

          await Alarm.stop(
            iqamaId,
          );

          await AndroidAlarmManager.cancel(
            countdownId,
          );

          cancelled++;
        } catch (e) {
          prayerSchedulerLog(
            '⚠️ Cancel error | '
                'date=$date | '
                'prayer=$p | '
                'error=$e',
          );
        }
      }
    }

    // ==========================================================
    // CANCEL COUNTDOWN NOTIFICATION
    // ==========================================================

    try {
      final notifications =
      FlutterLocalNotificationsPlugin();

      await notifications.cancel(
        id: countdownNotificationId,
      );
    } catch (e, stackTrace) {
      prayerSchedulerLog(
        '⚠️ Failed to cancel countdown notification',
      );

      prayerSchedulerLog(
        'ERROR = $e',
      );

      prayerSchedulerLog(
        'STACKTRACE = $stackTrace',
      );
    }

    // ==========================================================
    // CLEAR PREFS
    // ==========================================================

    await prefs.remove(
      prayerScheduledDaysPrefsKey,
    );

    await prefs.remove(
      prayerScheduledFromPrefsKey,
    );

    await prefs.remove(
      prayerNotificationWindowPrefsKey,
    );

    await prefs.remove(
      prayerScheduledLatitudePrefsKey,
    );

    await prefs.remove(
      prayerScheduledLongitudePrefsKey,
    );

    prayerSchedulerLog(
      '✅ cancelAll() completed | '
          'cancelled=$cancelled',
    );
  }
}