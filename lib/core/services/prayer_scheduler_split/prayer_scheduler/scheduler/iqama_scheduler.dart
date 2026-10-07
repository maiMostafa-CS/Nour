import 'package:alarm/alarm.dart';

import '../config/prayer_scheduler_config.dart';
import '../notifications/countdown_notification_service.dart';
import '../utils/prayer_scheduler_ids.dart';

class IqamaScheduler {
  const IqamaScheduler._();

  static Future<bool> schedule({
    required int dayIndex,
    required dynamic moment,
    required int iqamaMinutes,
  }) async {
    final id = PrayerSchedulerIds.iqama(
      moment.time,
      moment.index,
    );

    final iqamaTime = moment.time.add(
      Duration(minutes: iqamaMinutes),
    );

    prayerSchedulerLog(
      '🕋 IQAMA START | '
          'id=$id | '
          'prayer=${moment.name} | '
          'delay=${iqamaMinutes}min | '
          'iqamaTime=$iqamaTime',
    );

    if (!iqamaTime.isAfter(DateTime.now())) {
      prayerSchedulerLog(
        '⏭️ IQAMA SKIPPED | prayer=${moment.name}',
      );
      return false;
    }

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: iqamaTime,

      assetAudioPath: iqamaAsset,

      // Important: play audio once without looping
      loopAudio: false,

      vibrate: false,

      androidFullScreenIntent: false,

      allowAlarmOverlap: true,

      androidStopAlarmOnTermination: false,

      volumeSettings: VolumeSettings.fade(
        volume: 1.0,
        fadeDuration: const Duration(seconds: 1),
        volumeEnforced: false,
      ),

      notificationSettings: NotificationSettings(
        title: 'حان الآن وقت الإقامة',
        body: 'إقامة صلاة ${moment.name}',
        stopButton: 'إيقاف',
        icon: notificationIcon,

        // لو المستخدم عمل dismiss
        // يتم إيقاف الـ alarm
        androidStopAlarmOnDismiss: true,
      ),

      payload: 'iqama',
    );

    await Alarm.set(
      alarmSettings: alarmSettings,
    );

    prayerSchedulerLog(
      '✅ IQAMA Alarm.set SUCCESS | id=$id | time=$iqamaTime',
    );

    return true;
  }

  static Future<void> cancel({
    required DateTime time,
    required int prayerIndex,
  }) async {
    final id = PrayerSchedulerIds.iqama(time, prayerIndex);
    await Alarm.stop(id);
    prayerSchedulerLog('🔇 IQAMA CANCELLED | id=$id');
  }

  static Future<void> cancelAllIqamas() async {
    final alarms = await Alarm.getAlarms();
    for (final a in alarms) {
      if (a.payload == 'iqama') {
        await Alarm.stop(a.id);
      }
    }
  }
}