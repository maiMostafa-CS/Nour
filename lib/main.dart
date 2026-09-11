import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/adhan_scheduler_service.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/notifications/countdown_notification_service.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/scheduler/reminder_scheduler.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();
  final adhanScheduler = AdhanSchedulerService();
  await adhanScheduler.initialize();
  // ReminderAutoStop.attachOnce();
  await checkAndroidScheduleExactAlarmPermission();

  await adhanScheduler.requestBatteryOptimizationExemption();

  runApp(const IslamicApp());
}

Future<void> checkAndroidScheduleExactAlarmPermission() async {
  final status = await Permission.scheduleExactAlarm.status;
  prayerSchedulerLog('📋 Schedule exact alarm permission: $status');

  if (status.isDenied) {
    final result = await Permission.scheduleExactAlarm.request();
    prayerSchedulerLog('📋 Schedule exact alarm permission after request: $result');
  }
}