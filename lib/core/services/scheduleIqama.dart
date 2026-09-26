// import 'package:alarm/alarm.dart';
// import 'package:flutter/foundation.dart';
//
// class IqamaSchedulerService {
//   static const int iqamaIdOffset = 300;
//
//   static const Duration iqamaDelay = Duration(
//     minutes: 15,
//   );
//
//   /// جدولة إقامة الصلاة بعد الأذان بـ 15 دقيقة
//   static Future<void> scheduleIqama({
//     required int id,
//     required String prayerName,
//     required DateTime prayerTime,
//   }) async {
//     final now = DateTime.now();
//
//     final iqamaTime = prayerTime.add(iqamaDelay);
//
//     debugPrint(
//       '🕌 Iqama $id -> '
//           'prayer: $prayerName | '
//           'adhan: $prayerTime | '
//           'iqama: $iqamaTime | '
//           'isAfter: ${iqamaTime.isAfter(now)}',
//     );
//
//     // لو وقت الإقامة عدى
//     if (!iqamaTime.isAfter(now)) {
//       debugPrint(
//         '⏭️ Iqama $id skipped because time has passed',
//       );
//       return;
//     }
//
//     final alarmSettings = AlarmSettings(
//       id: id,
//
//       dateTime: iqamaTime,
//
//       // صوت الإقامة
//       assetAudioPath: 'assets/adhan-mp3/Iqama.mp3',
//
//       loopAudio: false,
//
//       vibrate: true,
//
//       androidFullScreenIntent: false,
//
//       androidStopAlarmOnTermination: false,
//
//       volumeSettings: VolumeSettings.fade(
//         volume: 1.0,
//         fadeDuration: const Duration(seconds: 1),
//         volumeEnforced: true,
//       ),
//
//       notificationSettings: NotificationSettings(
//         title: 'حان الآن وقت إقامة صلاة $prayerName',
//         body: 'حان وقت الإقامة',
//         stopButton: 'إيقاف الإقامة',
//         icon: 'ic_mosque_notification',
//         androidStopAlarmOnDismiss: true,
//       ),
//
//       payload: 'iqama',
//     );
//
//     final result = await Alarm.set(
//       alarmSettings: alarmSettings,
//     );
//
//     debugPrint(
//       '✅ Iqama scheduled successfully',
//     );
//
//     debugPrint(
//       '🕌 Prayer: $prayerName',
//     );
//
//     debugPrint(
//       '🕐 Iqama time: $iqamaTime',
//     );
//
//     debugPrint(
//       '🔊 Iqama result: $result',
//     );
//   }
//
//   /// إلغاء إقامة صلاة معينة
//   static Future<void> cancelIqama(int prayerNumber) async {
//     final id = prayerNumber + iqamaIdOffset;
//
//     await Alarm.stop(id);
//
//     debugPrint(
//       '🛑 Iqama cancelled: $id',
//     );
//   }
//
//   /// إلغاء جميع الإقامات
//   static Future<void> cancelAllIqamas() async {
//     for (int prayerNumber = 1; prayerNumber <= 5; prayerNumber++) {
//       await cancelIqama(prayerNumber);
//     }
//
//     debugPrint(
//       '🛑 All iqamas cancelled',
//     );
//   }
// }
