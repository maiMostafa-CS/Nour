// import 'package:alarm/alarm.dart';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:islamic_app/core/services/prayer_scheduler_split/prayer_scheduler/adhan_scheduler_service.dart';
// import 'package:islamic_app/core/services/prayer_scheduler_split/prayer_scheduler/background/prayer_background_callbacks.dart';
// import 'package:islamic_app/core/services/prayer_scheduler_split/prayer_scheduler/config/prayer_scheduler_config.dart';
// import 'package:islamic_app/core/services/prayer_scheduler_split/prayer_scheduler/data/datasources/prayer_notification_local_data_source_impl.dart';
// import 'package:islamic_app/core/services/prayer_scheduler_split/prayer_scheduler/notifications/countdown_notification_service.dart';
// import 'package:islamic_app/core/services/prayer_scheduler_split/prayer_scheduler/services/adhan_asset_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../features/adhan_settings/data/ datasources/adhan_settings_local_data_source.dart';
// import '../../features/adhan_settings/data/repositories/adhan_settings_repository_impl.dart';
// import '../../features/adhan_sound/data/datasources/adhan_local_data_source.dart';
// import '../../features/iqama_setting/data/datasources/iqama_settings_local_data_source.dart';
// import '../../features/iqama_setting/data/repositories/iqama_settings_repository_impl.dart';
// import '../../features/prayer_times/data/datasources/prayer_local_data_source.dart';
// const int kPrayerMaintenanceTestAlarmId = 999999;
// class AutoRenewTest {
//   const AutoRenewTest._();
//
//   // ============================================================
//   // TEST CONFIG
//   // ============================================================
//
//   static const int testWindowDays = 2;
//
//   // Reminder
//   static const int testReminderAlarmId = 99997;
//
//   // Adhan
//   static const int testAdhanAlarmId = 99999;
//
//   // Iqama
//   static const int testIqamaAlarmId = 99998;
//
//   // ============================================================
//   // RUN TEST
//   // ============================================================
//
//   static Future<void> run() async {
//     debugPrint('');
//     debugPrint('🧪 ========================================');
//     debugPrint('🧪 REMINDER + ADHAN + IQAMA REAL TEST');
//     debugPrint('🧪 ========================================');
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       // ============================================================
//       // 1️⃣ GET SAVED LOCATION
//       // ============================================================
//
//       final lat = prefs.getDouble(
//         prayerLastLatitudePrefsKey,
//       );
//
//       final lng = prefs.getDouble(
//         prayerLastLongitudePrefsKey,
//       );
//
//       debugPrint('📍 Saved latitude  = $lat');
//       debugPrint('📍 Saved longitude = $lng');
//
//       if (lat == null || lng == null) {
//         debugPrint(
//           '❌ TEST FAILED: coordinates are not saved',
//         );
//         return;
//       }
//
//       // ============================================================
//       // 2️⃣ CLEAN OLD TEST ALARMS
//       // ============================================================
//
//       await _stopTestAlarm(
//         testReminderAlarmId,
//         'REMINDER',
//       );
//
//       await _stopTestAlarm(
//         testAdhanAlarmId,
//         'ADHAN',
//       );
//
//       await _stopTestAlarm(
//         testIqamaAlarmId,
//         'IQAMA',
//       );
//
//       debugPrint('🧹 Old test alarms cleared');
//
//       // ============================================================
//       // 3️⃣ CREATE FAKE AUTO RENEW WINDOW
//       // ============================================================
//
//       final now = DateTime.now();
//
//       final today = DateTime(
//         now.year,
//         now.month,
//         now.day,
//       );
//
//       // حتى نقدر نختبر حالة أن الـ window قريبة من الانتهاء
//       final fakeScheduledFrom = today.subtract(
//         const Duration(days: 1),
//       );
//
//       await prefs.setInt(
//         prayerScheduledDaysPrefsKey,
//         testWindowDays,
//       );
//
//       await prefs.setString(
//         prayerScheduledFromPrefsKey,
//         fakeScheduledFrom.toIso8601String(),
//       );
//
//       debugPrint('');
//       debugPrint('🧪 ========================================');
//       debugPrint('🧪 FAKE AUTO RENEW WINDOW');
//       debugPrint('🧪 ========================================');
//       debugPrint(
//         '🧪 scheduledFrom = $fakeScheduledFrom',
//       );
//       debugPrint(
//         '🧪 scheduledDays = $testWindowDays',
//       );
//
//       // ============================================================
//       // 4️⃣ TEST TIMES
//       // ============================================================
//
//       // // Reminder بعد 20 ثانية
//       // final reminderTime = now.add(
//       //   const Duration(seconds: 10),
//       // );
//
//       // Adhan بعد 50 ثانية
//       final adhanTime = now.add(
//         const Duration(seconds: 10),
//       );
//
//       // Iqama بعد الأذان بـ 30 ثانية
//       final iqamaTime = adhanTime.add(
//         const Duration(seconds: 50),
//       );
//
//       debugPrint('');
//       debugPrint('🧪 ========================================');
//       debugPrint('🧪 TEST TIMES');
//       debugPrint('🧪 ========================================');
//
//       // debugPrint(
//       //   '🔔 Reminder time = $reminderTime',
//       // );
//
//       debugPrint(
//         '🔊 Adhan time    = $adhanTime',
//       );
//
//       debugPrint(
//         '🕌 Iqama time    = $iqamaTime',
//       );
//
//
//       // ============================================================
// //       // 5️⃣ SCHEDULE REMINDER
// //       // ============================================================
// //
// //       await Alarm.set(
// //         alarmSettings: AlarmSettings(
// //           id: testReminderAlarmId,
// //           dateTime: reminderTime,
// //
// //           assetAudioPath: reminderAsset,
// //
// //           loopAudio: false,
// //           vibrate: false,
// //
// //           androidFullScreenIntent: false,
// //           androidStopAlarmOnTermination: false,
// //
// //           volumeSettings: VolumeSettings.fixed(
// //             volume: 1.0,
// //             volumeEnforced: false,
// //           ),
// //
// //           notificationSettings:
// //           const NotificationSettings(
// //             title: '🔔 تذكير بالصلاة',
// //             body: 'اقترب موعد الأذان',
// //             stopButton: 'إيقاف التذكير',
// //             icon: notificationIcon,
// //             androidStopAlarmOnDismiss: true,
// //           ),
// //
// //           payload: 'auto_renew_test_reminder',
// //         ),
// //       );
// //
// //       debugPrint(
// //         '✅ REMINDER TEST ALARM SET '
// //             '| id=$testReminderAlarmId',
// //       );
// //
// //
// //
// // // 🔍 VERIFY ADHAN ALARM
// //       try {
// //         final alarm = await Alarm.getAlarm(
// //           testAdhanAlarmId,
// //         );
// //
// //         debugPrint(
// //           '🔍 ADHAN CHECK | '
// //               'exists=${alarm != null} | '
// //               'time=${alarm?.dateTime}',
// //         );
// //       } catch (e, stackTrace) {
// //         debugPrint(
// //           '❌ ADHAN CHECK FAILED | error=$e',
// //         );
// //
// //         debugPrint(
// //           'STACKTRACE: $stackTrace',
// //         );
// //       }
// //       debugPrint(
// //         '✅ ADHAN TEST ALARM SET '
// //             '| id=$testAdhanAlarmId',
// //       );
//
//       // ============================================================
//       // 7️⃣ SCHEDULE IQAMA
//       // ============================================================
//
//       // ============================================================
//       // 6️⃣ SCHEDULE ADHAN
//       // ============================================================
//
//       await Alarm.set(
//         alarmSettings:
//         AlarmSettings(
//           id: testAdhanAlarmId,
//           dateTime: adhanTime,
//           assetAudioPath: adhanAsset,
//           loopAudio: false,
//           vibrate: false,
//           androidFullScreenIntent: false,
//           androidStopAlarmOnTermination: false,
//           allowAlarmOverlap: true, // 👈 ضيفها هنا
//           volumeSettings: VolumeSettings.fixed(volume: 1.0, volumeEnforced: false),
//           notificationSettings: const NotificationSettings(
//             title: '🕌 اختبار الأذان',
//             body: 'حان الآن وقت الأذان',
//             stopButton: 'إيقاف الأذان',
//             icon: notificationIcon,
//             androidStopAlarmOnDismiss: false,
//           ),
//           payload: 'auto_renew_test_adhan',
//         ),
//       );
//       debugPrint(
//         '✅ ADHAN TEST ALARM SET '
//             '| id=$testAdhanAlarmId',
//       );
//
//
//       await Alarm.set(
//         alarmSettings: AlarmSettings(
//           id: testIqamaAlarmId,
//           dateTime: iqamaTime,
//           assetAudioPath: iqamaAsset,
//           loopAudio: false,
//           vibrate: false,
//           androidFullScreenIntent: false,
//           androidStopAlarmOnTermination: false,
//           allowAlarmOverlap: true, // 👈 وهنا كمان
//           volumeSettings: VolumeSettings.fixed(volume: 1.0, volumeEnforced: false),
//           notificationSettings: const NotificationSettings(
//             title: '🕌 اختبار الإقامة',
//             body: 'حان الآن وقت الإقامة',
//             stopButton: 'إيقاف الإقامة',
//             icon: notificationIcon,
//             androidStopAlarmOnDismiss: true,
//           ),
//           payload: 'auto_renew_test_iqama',
//         ),
//       );
//       debugPrint(
//         '✅ IQAMA TEST ALARM SET '
//             '| id=$testIqamaAlarmId',
//       );
//
//       // ============================================================
//       // 8️⃣ TEST TIMELINE
//       // ============================================================
//
//       debugPrint('');
//       debugPrint('⏳ ========================================');
//       debugPrint('⏳ TEST TIMELINE');
//       debugPrint('⏳ ========================================');
//
//       debugPrint(
//         '⏳ بعد 20 ثانية  → 🔔 التذكير',
//       );
//
//       debugPrint(
//         '⏳ بعد 50 ثانية  → 🔊 الأذان',
//       );
//
//       debugPrint(
//         '⏳ بعد 80 ثانية  → 🕌 الإقامة',
//       );
//
//       debugPrint('');
//       debugPrint('✅ ========================================');
//       debugPrint('✅ ALL TEST ALARMS SCHEDULED');
//       debugPrint('✅ ========================================');
//       debugPrint('');
//     } catch (e, stackTrace) {
//       debugPrint('');
//       debugPrint('❌ ========================================');
//       debugPrint('❌ TEST FAILED');
//       debugPrint('❌ ========================================');
//       debugPrint('❌ ERROR: $e');
//       debugPrint('❌ STACKTRACE: $stackTrace');
//     }
//   }
//
//   // ============================================================
//   // STOP ONE TEST ALARM
//   // ============================================================
//
//   static Future<void> _stopTestAlarm(
//       int id,
//       String name,
//       ) async {
//     try {
//       await Alarm.stop(id);
//
//       debugPrint(
//         '🛑 Old $name alarm stopped | id=$id',
//       );
//     } catch (e) {
//       debugPrint(
//         'ℹ️ No old $name alarm to stop | id=$id',
//       );
//     }
//   }
//
//   // ============================================================
//   // CANCEL ALL TEST ALARMS
//   // ============================================================
//
//   static Future<void> cancel() async {
//     debugPrint('');
//     debugPrint('🛑 ========================================');
//     debugPrint('🛑 CANCELLING TEST ALARMS');
//     debugPrint('🛑 ========================================');
//
//     await _stopTestAlarm(
//       testReminderAlarmId,
//       'REMINDER',
//     );
//
//     await _stopTestAlarm(
//       testAdhanAlarmId,
//       'ADHAN',
//     );
//
//     await _stopTestAlarm(
//       testIqamaAlarmId,
//       'IQAMA',
//     );
//
//     debugPrint('');
//     debugPrint(
//       '🛑 Reminder + Adhan + Iqama '
//           'test alarms cancelled',
//     );
//     debugPrint('');
//   }
// }
// Future<void> scheduleMaintenanceTestAlarm() async {
//   prayerSchedulerLog(
//     '🧪 Scheduling TEST maintenance alarm in 1 minute...',
//   );
//
//   final result = await AndroidAlarmManager.oneShot(
//     const Duration(minutes: 1),
//     kPrayerMaintenanceTestAlarmId,
//     prayerScheduleMaintenanceCallback,
//     exact: true,
//     wakeup: true,
//     rescheduleOnReboot: false,
//   );
//
//   prayerSchedulerLog(
//     '🧪 TEST maintenance alarm scheduled | result=$result',
//   );
// }
// @pragma('vm:entry-point')
// Future<void> prayerScheduleMaintenanceCallback() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   prayerSchedulerLog(
//     '🚨🚨🚨 MAINTENANCE CALLBACK FIRED 🚨🚨🚨',
//   );
//
//   try {
//     final prefs = await SharedPreferences.getInstance();
//
//     final latitude =
//     prefs.getDouble(prayerLastLatitudePrefsKey);
//
//     final longitude =
//     prefs.getDouble(prayerLastLongitudePrefsKey);
//
//     prayerSchedulerLog(
//       '📍 MAINTENANCE LOCATION = $latitude, $longitude',
//     );
//
//     if (latitude == null || longitude == null) {
//       prayerSchedulerLog(
//         '❌ MAINTENANCE: location not found',
//       );
//       return;
//     }
//
//     final adhanLocalDataSource = AdhanLocalDataSourceImpl(prefs: prefs);
//
//     final dataSource = PrayerNotificationLocalDataSourceImpl(
//       prayerCalculator: PrayerLocalDataSourceImpl(),
//       adhanSettingsRepository: AdhanSettingsRepositoryImpl(
//         localDataSource: AdhanSettingsLocalDataSourceImpl(prefs: prefs),
//       ),
//       iqamaSettingsRepository: IqamaSettingsRepositoryImpl(
//         localDataSource: IqamaSettingsLocalDataSourceImpl(prefs: prefs),
//       ),
//       adhanLocalDataSource: adhanLocalDataSource,
//       adhanAssetProvider: AdhanAssetProvider(
//         localDataSource: adhanLocalDataSource,
//       ),
//     );
//
//     prayerSchedulerLog(
//       '🔍 MAINTENANCE → ensureWindowScheduled()',
//     );
//
//     await dataSource.ensureWindowScheduled(
//       latitude: latitude,
//       longitude: longitude,
//       days: kPrayerNotificationWindowDays,
//     );
//
//     prayerSchedulerLog(
//       '✅ MAINTENANCE CALLBACK COMPLETED',
//     );
//   } catch (e, stackTrace) {
//     prayerSchedulerLog(
//       '❌ Prayer maintenance failed: $e',
//     );
//
//     prayerSchedulerLog(
//       'STACKTRACE: $stackTrace',
//     );
//   }
// }