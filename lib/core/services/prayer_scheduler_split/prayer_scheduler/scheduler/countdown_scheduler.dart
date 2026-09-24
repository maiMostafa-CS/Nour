import 'package:flutter/widgets.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import '../background/countdown_callbacks.dart';
import '../background/prayer_background_callbacks.dart';
import '../notifications/countdown_notification_service.dart';
import '../utils/prayer_scheduler_ids.dart';

class CountdownScheduler {
  const CountdownScheduler._();

  static Future<void> schedule({
    required dynamic moment,
  }) async {
    final DateTime scheduledTime = moment.time as DateTime;

    final id = PrayerSchedulerIds.countdownUpdate(
      scheduledTime,
      moment.index,
    );

    prayerSchedulerLog(
      '⏱️ COUNTDOWN START | '
          'id=$id | '
          'prayer=${moment.name} | '
          'time=$scheduledTime',
    );

    if (!scheduledTime.isAfter(DateTime.now())) {
      prayerSchedulerLog(
        '⏭️ COUNTDOWN SKIPPED | الوقت فات بالفعل',
      );
      return;
    }

    try {
      await AndroidAlarmManager.cancel(id);

      final result = await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        id,
        updatePrayerNotificationCountdownCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );

      prayerSchedulerLog(
        '🔁 AndroidAlarmManager RESULT | '
            'id=$id | '
            'result=$result | '
            'time=$scheduledTime',
      );
    } catch (e, stackTrace) {
      prayerSchedulerLog(
        '❌ COUNTDOWN ANDROID ALARM FAILED | '
            'id=$id | '
            'error=$e',
      );

      prayerSchedulerLog(
        'STACKTRACE: $stackTrace',
      );
    }
  }
}