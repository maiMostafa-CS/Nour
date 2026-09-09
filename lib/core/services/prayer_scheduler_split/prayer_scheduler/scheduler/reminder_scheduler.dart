// // import 'dart:async';
// //
// // import 'package:alarm/alarm.dart';
// //
// // import '../config/prayer_scheduler_config.dart';
// // import '../notifications/countdown_notification_service.dart';
// // import '../utils/prayer_scheduler_assets.dart';
// // import '../utils/prayer_scheduler_ids.dart';
// //
// // class ReminderScheduler {
// //   const ReminderScheduler._();
// //
// //   static Future<void> schedule({
// //     required int dayIndex,
// //     required dynamic moment,
// //   }) async {
// //     final id = PrayerSchedulerIds.reminder(
// //       moment.time,
// //       moment.index,
// //     );
// //
// //     final reminderTime =
// //         moment.time.subtract(const Duration(minutes: 5));
// //
// //     prayerSchedulerLog(
// //       '🔔 REMINDER START | id=$id | prayer=${moment.name} | time=$reminderTime',
// //     );
// //
// //     if (!reminderTime.isAfter(DateTime.now())) {
// //       prayerSchedulerLog('⏭️ REMINDER SKIPPED');
// //       return;
// //     }
// //
// //     final alarmSettings = AlarmSettings(
// //       id: id,
// //       dateTime: reminderTime,
// //       assetAudioPath: PrayerSchedulerAssets.reminder(moment.name),
// //       loopAudio: false,
// //       vibrate: false,
// //       androidFullScreenIntent: false,
// //       androidStopAlarmOnTermination: false,
// //       volumeSettings: VolumeSettings.fade(
// //         volume: 1.0,
// //         fadeDuration: const Duration(seconds: 1),
// //         volumeEnforced: true,
// //       ),
// //       notificationSettings: NotificationSettings(
// //         title: 'اقترب موعد صلاة ${moment.name}',
// //         body: 'باقي 5 دقائق على أذان ${moment.name}',
// //         stopButton: 'إيقاف التنبيه',
// //         icon: notificationIcon,
// //         androidStopAlarmOnDismiss: false,
// //       ),
// //       payload: 'reminder_before_adhan',
// //     );
// //
// //     await Alarm.set(alarmSettings: alarmSettings);
// //     Timer(const Duration(seconds: 6), () async {
// //       if (await Alarm.isRinging(id)) {
// //         await Alarm.stop(id);
// //       }
// //     });
// //     prayerSchedulerLog(
// //       '✅ REMINDER Alarm.set SUCCESS | id=$id',
// //     );
// //   }
// // }
// import 'dart:async';
//
// import 'package:alarm/alarm.dart';
// import 'package:flutter/cupertino.dart';
//
// import '../config/prayer_scheduler_config.dart';
// import '../notifications/countdown_notification_service.dart';
// import '../utils/prayer_scheduler_assets.dart';
// import '../utils/prayer_scheduler_ids.dart';
//
// class ReminderScheduler {
//   const ReminderScheduler._();
//
//   static Future<void> schedule({
//     required int dayIndex,
//     required dynamic moment,
//   }) async {
//     final id = PrayerSchedulerIds.reminder(
//       moment.time,
//       moment.index,
//     );
//
//     final reminderTime =
//     moment.time.subtract(const Duration(minutes: 5));
//
//     prayerSchedulerLog(
//       '🔔 REMINDER START | id=$id | prayer=${moment.name} | time=$reminderTime',
//     );
//
//     if (!reminderTime.isAfter(DateTime.now())) {
//       prayerSchedulerLog('⏭️ REMINDER SKIPPED');
//       return;
//     }
//
//     final alarmSettings = AlarmSettings(
//       id: id,
//       dateTime: reminderTime,
//       assetAudioPath: PrayerSchedulerAssets.reminder(moment.name),
//       loopAudio: false,
//       vibrate: false,
//       androidFullScreenIntent: false,
//       androidStopAlarmOnTermination: false,
//       allowAlarmOverlap: true,
//       volumeSettings: VolumeSettings.fade(
//         volume: 1.0,
//         fadeDuration: const Duration(seconds: 1),
//         volumeEnforced: true,
//       ),
//       notificationSettings: NotificationSettings(
//         title: 'اقترب موعد صلاة ${moment.name}',
//         body: 'باقي 5 دقائق على أذان ${moment.name}',
//         stopButton: 'إيقاف التنبيه',
//         icon: notificationIcon,
//         androidStopAlarmOnDismiss: false,
//       ),
//       payload: 'reminder_before_adhan',
//     );
//
//     await Alarm.set(alarmSettings: alarmSettings);
//
//     prayerSchedulerLog(
//       '✅ REMINDER Alarm.set SUCCESS | id=$id',
//     );
//
//     Timer(const Duration(seconds: 8), () async {
//       final stillRinging = await Alarm.isRinging(id);
//       prayerSchedulerLog(
//         stillRinging
//             ? '⚠️ REMINDER STILL RINGING (لسه متقفلش) | id=$id → هيتقفل يدويًا دلوقتي'
//             : '🛑 REMINDER ALREADY STOPPED (اتقفل عادي) | id=$id',
//       );
//
//       if (stillRinging) {
//         await Alarm.stop(id);
//         prayerSchedulerLog('✅ REMINDER FORCE-STOPPED | id=$id');
//       }
//     });
//   }
// }
// const reminderPayload = 'auto_renew_test_reminder';
// class ReminderAutoStop {
//   static bool _attached = false;
//
//   /// نادِ الدالة دي مرة واحدة بس في main() بعد Alarm.init()
//   static void attachOnce() {
//     if (_attached) return;
//     _attached = true;
//
//     Alarm.ringing.listen((alarmSet) {
//       for (final alarm in alarmSet.alarms) {
//         if (alarm.payload == reminderPayload) {
//           debugPrint('🔔 REMINDER RINGING NOW | id=${alarm.id}');
//
//           // اديله وقت كافي إن الصوت يخلص (عدّل الرقم حسب طول ملف الصوت بتاعك)
//           Timer(const Duration(seconds: 5), () async {
//             final stillRinging = await Alarm.isRinging(alarm.id);
//             debugPrint(
//               stillRinging
//                   ? '⚠️ REMINDER STILL RINGING → قافله دلوقتي'
//                   : '🛑 REMINDER ALREADY STOPPED',
//             );
//             if (stillRinging) {
//               await Alarm.stop(alarm.id);
//               debugPrint('✅ REMINDER FORCE-STOPPED | id=${alarm.id}');
//             }
//           });
//         }
//       }
//     });
//   }
// }