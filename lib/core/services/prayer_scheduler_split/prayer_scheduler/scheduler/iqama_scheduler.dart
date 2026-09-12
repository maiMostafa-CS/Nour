import 'package:alarm/alarm.dart';

import '../config/prayer_scheduler_config.dart';
import '../notifications/countdown_notification_service.dart';
import '../utils/prayer_scheduler_ids.dart';

class IqamaScheduler {
  const IqamaScheduler._();

  static Future<void> schedule({
    required int dayIndex,
    required dynamic moment,
    required int iqamaMinutes,
  }) async {
    final id = PrayerSchedulerIds.iqama(
      moment.time,
      moment.index,
    );

    // ==========================================================
    // IQAMA TIME
    // ==========================================================

    final iqamaTime = moment.time.add(
      Duration(
        minutes: iqamaMinutes,
      ),
    );

    prayerSchedulerLog(
      '🕋 IQAMA START | '
          'id=$id | '
          'prayer=${moment.name} | '
          'delay=${iqamaMinutes}min | '
          'prayerTime=${moment.time} | '
          'iqamaTime=$iqamaTime',
    );

    // ==========================================================
    // CHECK FUTURE
    // ==========================================================

    if (!iqamaTime.isAfter(DateTime.now())) {
      prayerSchedulerLog(
        '⏭️ IQAMA SKIPPED | '
            'prayer=${moment.name} | '
            'iqamaTime=$iqamaTime',
      );

      return;
    }

    // ==========================================================
    // ALARM SETTINGS
    // ==========================================================

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: iqamaTime,
      assetAudioPath: iqamaAsset,
      loopAudio: false,
      vibrate: false,
      androidFullScreenIntent: false,
      allowAlarmOverlap: true,
      androidStopAlarmOnTermination: false,
      volumeSettings: VolumeSettings.fade(
        volume: 1.0,
        fadeDuration: const Duration(seconds: 1),
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: 'حان الآن وقت الإقامة',
        body: 'إقامة صلاة ${moment.name}',
        stopButton: 'إيقاف',
        icon: notificationIcon,
        androidStopAlarmOnDismiss: true,
      ),
      payload: 'iqama',
    );

    // ==========================================================
    // SET ALARM
    // ==========================================================

    await Alarm.set(
      alarmSettings: alarmSettings,
    );

    prayerSchedulerLog(
      '✅ IQAMA Alarm.set SUCCESS | '
          'id=$id | '
          'prayer=${moment.name} | '
          'delay=${iqamaMinutes}min | '
          'time=$iqamaTime',
    );
  }
}