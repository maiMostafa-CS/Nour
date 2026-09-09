import 'package:alarm/alarm.dart';

import '../config/prayer_scheduler_config.dart';
import '../notifications/countdown_notification_service.dart';
import '../utils/prayer_scheduler_ids.dart';

class IqamaScheduler {
  const IqamaScheduler._();

  static Future<void> schedule({
    required int dayIndex,
    required dynamic moment,
  }) async {
    final id = PrayerSchedulerIds.iqama(
      moment.time,
      moment.index,
    );

    final iqamaTime =
        moment.time.add(const Duration(minutes: 15));

    prayerSchedulerLog(
      '🕋 IQAMA START | id=$id | prayer=${moment.name} | time=$iqamaTime',
    );

    if (!iqamaTime.isAfter(DateTime.now())) {
      prayerSchedulerLog('⏭️ IQAMA SKIPPED');
      return;
    }

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: iqamaTime,
      assetAudioPath: iqamaAsset,
      loopAudio: false,
      vibrate: false,
      androidFullScreenIntent: false,
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

    await Alarm.set(alarmSettings: alarmSettings);

    prayerSchedulerLog(
      '✅ IQAMA Alarm.set SUCCESS | id=$id',
    );
  }
}
