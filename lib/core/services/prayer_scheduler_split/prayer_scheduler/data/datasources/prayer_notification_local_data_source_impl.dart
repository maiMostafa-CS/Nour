import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../features/prayer_times/data/datasources/prayer_local_data_source.dart';
import '../../../../../../features/prayer_times/domain/entities/PrayerDayScheduleEntity.dart';
import '../../../../adhan_scheduler_service.dart' as legacy;
import '../../config/prayer_scheduler_config.dart';
import '../../notifications/countdown_notification_service.dart';
import '../../scheduler/adhan_scheduler.dart';
import '../../scheduler/countdown_scheduler.dart';
import '../../scheduler/iqama_scheduler.dart';
import '../../scheduler/reminder_scheduler.dart';
import '../../utils/prayer_scheduler_ids.dart';
import 'prayer_notification_local_data_source.dart';

class PrayerNotificationLocalDataSourceImpl
    implements PrayerNotificationLocalDataSource {
  PrayerNotificationLocalDataSourceImpl({
    required PrayerLocalDataSource prayerCalculator,
  }) : _prayerCalculator = prayerCalculator;

  final PrayerLocalDataSource _prayerCalculator;

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

    // Rolling scheduling: never cancel existing future alarms here.
    // Alarm IDs are deterministic, so scheduling the same prayer updates it safely.
    final windowEntries = <Map<String, String>>[];

    var scheduledAdhans = 0;
    var scheduledReminders = 0;
    var scheduledIqamas = 0;
    var scheduledCountdowns = 0;

    for (var dayIndex = 0; dayIndex < schedule.length; dayIndex++) {
      final day = schedule[dayIndex];

      for (final moment in day.toMoments()) {


        final reminderTime =
        moment.time.subtract(const Duration(minutes: 5));

        // if (reminderTime.isAfter(now)) {
        //   try {
        //     await ReminderScheduler.schedule(
        //       dayIndex: dayIndex,
        //       moment: moment,
        //     );
        //     scheduledReminders++;
        //   } catch (e, stackTrace) {
        //     prayerSchedulerLog('❌ Reminder FAILED: $e');
        //     prayerSchedulerLog('STACKTRACE: $stackTrace');
        //   }
        // }
        final adhanScheduled = await AdhanScheduler.schedule(
          dayIndex: dayIndex,
          moment: moment,
        );

        if (adhanScheduled) {
          scheduledAdhans++;
        }

        final iqamaTime =
        moment.time.add(const Duration(minutes: 15));

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

        if (moment.time.isAfter(now)) {
          try {
            await CountdownScheduler.schedule(
              moment: moment,
            );
            scheduledCountdowns++;
          } catch (e, stackTrace) {
            prayerSchedulerLog('❌ Countdown update FAILED: $e');
            prayerSchedulerLog('STACKTRACE: $stackTrace');
          }
        }

        windowEntries.add({
          'name': moment.name,
          'time': moment.time.toIso8601String(),
        });
      }
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      prayerScheduledDaysPrefsKey,
      days,
    );

    await prefs.setString(
      prayerScheduledFromPrefsKey,
      today.toIso8601String(),
    );

    await prefs.setDouble(prayerLastLatitudePrefsKey, latitude);
    await prefs.setDouble(prayerLastLongitudePrefsKey, longitude);
    await prefs.setString(
      prayerNotificationWindowPrefsKey,
      jsonEncode(windowEntries),
    );

    try {
      await CountdownNotificationService.showNextPrayerCountdown();
    } catch (e, stackTrace) {
      prayerSchedulerLog('❌ Initial countdown FAILED: $e');
      prayerSchedulerLog('STACKTRACE: $stackTrace');
    }

    prayerSchedulerLog('🎉 SCHEDULING FINISHED SUCCESSFULLY');
    prayerSchedulerLog('📅 Days = $days');
    prayerSchedulerLog('🕌 Adhans = $scheduledAdhans');
    prayerSchedulerLog('🔔 Reminders = $scheduledReminders');
    prayerSchedulerLog('🕋 Iqamas = $scheduledIqamas');
    prayerSchedulerLog('⏱️ Countdown updates = $scheduledCountdowns');
    prayerSchedulerLog('📦 Total entries = ${windowEntries.length}');
    prayerSchedulerLog('════════════════════════════════════');
  }

  /// يتأكد إن فيه [days] يوم قدام دايماً مجدولين (نافذة متجددة).
  ///
  /// بيقرأ آخر تاريخ اتجدولت منه النافذة (`prayerScheduledFromPrefsKey`)
  /// وعدد الأيام اللي اتجدولوا (`prayerScheduledDaysPrefsKey`)، وبيحسب
  /// كام يوم "متبقي" فعلياً من النافذة القديمة من النهاردة. لو المتبقي
  /// أقل من [days] (يعني النافذة قربت تخلص أو فيه فجوة)، بينادي
  /// [scheduleForDays] عشان يعيد بناء نافذة كاملة [days] يوم من النهاردة.
  ///
  /// لو النافذة لسه كافية، الدالة مبتعملش حاجة (تجنباً لعمل cancel +
  /// reschedule كامل لكل الـ Alarms من غير داعي).
  @override
  Future<void> ensureWindowScheduled({
    required double latitude,
    required double longitude,
    int days = 30,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final scheduledFromIso = prefs.getString(prayerScheduledFromPrefsKey);
    final scheduledDays = prefs.getInt(prayerScheduledDaysPrefsKey);

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    var needsReschedule = true;

    if (scheduledFromIso != null && scheduledDays != null) {
      final scheduledFrom = DateTime.parse(scheduledFromIso);
      final lastCoveredDay =
      scheduledFrom.add(Duration(days: scheduledDays - 1));

      // كام يوم "كامل" فاضل من آخر يوم مغطى، ابتداءً من النهاردة؟
      final daysRemaining = lastCoveredDay.difference(today).inDays;

      // لو لسه فاضل نفس عدد الأيام المطلوب (أو أكتر)، النافذة كويسة.
      // Renew in the background every couple of days worth of coverage,
      // while keeping existing alarms untouched.
      needsReschedule = daysRemaining < 2;

      prayerSchedulerLog(
        '🔎 ensureWindowScheduled: daysRemaining=$daysRemaining, '
            'needed=${days - 1}, needsReschedule=$needsReschedule',
      );
    } else {
      prayerSchedulerLog(
        '🔎 ensureWindowScheduled: no previous window found, scheduling fresh',
      );
    }

    if (needsReschedule) {
      await scheduleForDays(
        latitude: latitude,
        longitude: longitude,
        days: days,
      );
    }
  }

  /// بتتنادى من الـ Alarm.ringing listener بعد كل أذان/تنبيه/إقامة يرن.
  /// دي هي نقطة الـ "auto-renew": مش بتعمل حاجة تقيلة كل مرة، بس بتتأكد
  /// (عن طريق [ensureWindowScheduled]) إن النافذة لسه كافية، وتمدها لو لأ.
  @override
  Future<void> onAlarmFired({
    required double latitude,
    required double longitude,
    int days = 30,
  }) {
    return ensureWindowScheduled(
      latitude: latitude,
      longitude: longitude,
      days: days,
    );
  }

  @override
  Future<void> cancelAll() async {
    prayerSchedulerLog('🛑 START cancelAll()');

    final prefs = await SharedPreferences.getInstance();

    final previousDays = prefs.getInt(prayerScheduledDaysPrefsKey) ?? 30;
    final scheduledFromIso = prefs.getString(prayerScheduledFromPrefsKey);
    final scheduledFrom = scheduledFromIso != null
        ? DateTime.tryParse(scheduledFromIso)
        : null;

    // Clear by real calendar dates so IDs never collide with a new rolling window.
    final firstDay = scheduledFrom ?? DateTime.now();
    final daysToClear = previousDays.clamp(1, 60);

    var cancelled = 0;

    for (var d = 0; d < daysToClear; d++) {
      final date = DateTime(firstDay.year, firstDay.month, firstDay.day + d);
      for (var p = 0; p < 5; p++) {
        final adhanId = PrayerSchedulerIds.adhan(date, p);
        final reminderId = PrayerSchedulerIds.reminder(date, p);
        final iqamaId = PrayerSchedulerIds.iqama(date, p);
        final countdownId = PrayerSchedulerIds.countdownUpdate(date, p);

        try {
          await Alarm.stop(adhanId);
          await Alarm.stop(reminderId);
          await Alarm.stop(iqamaId);
          await AndroidAlarmManager.cancel(countdownId);
          cancelled++;
        } catch (e) {
          prayerSchedulerLog('⚠️ Cancel error | date=$date | prayer=$p | error=$e');
        }
      }
    }

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

    await prefs.remove(prayerScheduledDaysPrefsKey);
    await prefs.remove(prayerScheduledFromPrefsKey);
    await prefs.remove(prayerNotificationWindowPrefsKey);

    prayerSchedulerLog(
      '✅ cancelAll() completed | cancelled=$cancelled',
    );
  }
}