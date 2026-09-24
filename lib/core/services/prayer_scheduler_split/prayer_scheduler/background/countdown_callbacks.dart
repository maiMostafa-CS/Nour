// import 'package:flutter/widgets.dart';
//
// import '../config/prayer_scheduler_config.dart';
// import '../notifications/countdown_notification_service.dart';
//
// @pragma('vm:entry-point')
// Future<void> updatePrayerNotificationCountdownCallback() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   prayerSchedulerLog(
//     '🚀🚀🚀 BACKGROUND COUNTDOWN CALLBACK STARTED',
//   );
//
//   try {
//     await CountdownNotificationService.showNextPrayerCountdown();
//
//     prayerSchedulerLog(
//       '✅ BACKGROUND CALLBACK FINISHED',
//     );
//   } catch (e, stackTrace) {
//     prayerSchedulerLog(
//       '❌ BACKGROUND CALLBACK FAILED: $e',
//     );
//     prayerSchedulerLog('STACKTRACE: $stackTrace');
//   }
// }