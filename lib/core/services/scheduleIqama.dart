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
//   /// Schedule iqama 15 minutes after adhan
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
//     // If the iqama time has passed
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
//       // Iqama audio
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
//         title: 'It is now time for iqama of $prayerName',
//         body: 'It is time for iqama',
//         stopButton: 'Stop iqama',
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
//   /// Cancel a specific iqama
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
//   /// Cancel all iqamas
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
