import 'package:alarm/alarm.dart';

import '../config/prayer_scheduler_config.dart';
import '../notifications/countdown_notification_service.dart';
import '../utils/prayer_scheduler_ids.dart';

class AdhanScheduler {
  const AdhanScheduler._();

  static Future<bool> schedule({
    required int dayIndex,
    required dynamic moment,
    required String adhanAssetPath,
  }) async {
    final id = PrayerSchedulerIds.adhan(
      moment.time,
      moment.index,
    );

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

        androidFullScreenIntent: false,

        androidStopAlarmOnTermination: false,
        allowAlarmOverlap: true,

        volumeSettings: VolumeSettings.fade(
          volume: 1.0,
          fadeDuration: const Duration(seconds: 1),
          volumeEnforced: true,
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

      prayerSchedulerLog(
        '✅ ADHAN Alarm.set SUCCESS | '
            'id=$id | '
            'prayer=${moment.name} | '
            'time=${moment.time} | '
            'asset=$adhanAssetPath',
      );

      return true;
    } catch (e, stackTrace) {
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
}