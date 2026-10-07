import 'package:alarm/alarm.dart';

import '../config/prayer_scheduler_config.dart';
import '../notifications/countdown_notification_service.dart';
import '../utils/prayer_alarm_logger.dart';
import '../utils/prayer_scheduler_ids.dart';

class AdhanScheduler {
  const AdhanScheduler._();

  static Future<bool> schedule({
    required int dayIndex,
    required dynamic moment,
    required String adhanAssetPath,
    required bool enabled,
  }) async {
    final id = PrayerSchedulerIds.adhan(
      moment.time,
      moment.index,
    );

    PrayerAlarmLogger.log(
      type: 'ADHAN',
      stage: 'SCHEDULE',
      prayerName: moment.name,
      alarmId: id,
      scheduledTime: moment.time,
      status: enabled ? 'INITIATING_SCHEDULE' : 'DISABLED',
    );

    if (!enabled) {
      await Alarm.stop(id);
      prayerSchedulerLog('🔇 ADHAN DISABLED | id=$id');
      return false;
    }
    prayerSchedulerLog(
      '🔊 ADHAN START | '
          'id=$id | '
          'prayer=${moment.name} | '
          'time=${moment.time} | '
          'asset=$adhanAssetPath',
    );

    final now = DateTime.now();

    if (!moment.time.isAfter(now)) {
      prayerSchedulerLog(
        '⏭️ ADHAN SKIPPED - time already passed | '
            'id=$id',
      );

      return false;
    }

    try {
      final alarmSettings = AlarmSettings(
        id: id,
        dateTime: moment.time,

        // ======================================================
        // ADHAN AUDIO
        //
        // Fajr:
        //     fajrAdhanAssetPath
        //
        // Other prayers:
        //     normalAdhanAssetPath
        //
        // The correct path is selected by
        // PrayerNotificationLocalDataSourceImpl.
        // ======================================================

        assetAudioPath: adhanAssetPath,

        loopAudio: false,
        vibrate: false,


        // ======================================================
        // false → Adhan plays + shows a notification (with stop
        // button) WITHOUT opening the app / activity.
        androidFullScreenIntent: false,

        androidStopAlarmOnTermination: false,
        allowAlarmOverlap: true,

        volumeSettings: VolumeSettings.fade(
          volume: 1.0,
          fadeDuration: const Duration(seconds: 1),
          volumeEnforced: false,
        ),

        notificationSettings: NotificationSettings(
          title: 'حان الآن وقت ${moment.name}',
          body: 'الله أكبر، الله أكبر',
          stopButton: 'إيقاف الأذان',
          icon: notificationIcon,

          androidStopAlarmOnDismiss: false,
        ),

        payload: 'adhan',
      );

      await Alarm.set(
        alarmSettings: alarmSettings,
      );

      PrayerAlarmLogger.log(
        type: 'ADHAN',
        stage: 'ALARM CREATED',
        prayerName: moment.name,
        alarmId: id,
        scheduledTime: moment.time,
        status: 'SUCCESS',
      );

      prayerSchedulerLog(
        '✅ ADHAN Alarm.set SUCCESS | '
            'id=$id | '
            'prayer=${moment.name} | '
            'time=${moment.time} | '
            'asset=$adhanAssetPath',
      );

      return true;
    } catch (e, stackTrace) {
      PrayerAlarmLogger.log(
        type: 'ADHAN',
        stage: 'ALARM CREATED',
        prayerName: moment.name,
        alarmId: id,
        scheduledTime: moment.time,
        status: 'FAILED',
        error: e,
        stackTrace: stackTrace,
      );

      prayerSchedulerLog(
        '❌ ADHAN Alarm.set FAILED | '
            'id=$id | '
            'prayer=${moment.name}',
      );

      prayerSchedulerLog(
        'ERROR = $e',
      );

      prayerSchedulerLog(
        'STACKTRACE: $stackTrace',
      );

      return false;
    }
  }

  static Future<void> cancel({
    required DateTime time,
    required int prayerIndex,
    String prayerName = 'Unknown',
  }) async {
    final id = PrayerSchedulerIds.adhan(time, prayerIndex);
    await Alarm.stop(id);
    PrayerAlarmLogger.log(
      type: 'ADHAN',
      stage: 'STOP ADHAN',
      prayerName: prayerName,
      alarmId: id,
      scheduledTime: time,
      status: 'CANCELLED',
    );
    prayerSchedulerLog('🔇 ADHAN CANCELLED | id=$id');
  }

  static Future<void> cancelAllAdhans() async {
    final alarms = await Alarm.getAlarms();
    for (final a in alarms) {
      if (a.payload == 'adhan') {
        await Alarm.stop(a.id);
      }
    }
  }
}