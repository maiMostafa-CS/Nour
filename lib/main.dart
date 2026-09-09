import 'package:flutter/cupertino.dart';
import 'app.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/adhan_scheduler_service.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/scheduler/reminder_scheduler.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();
  final adhanScheduler = AdhanSchedulerService();
  await adhanScheduler.initialize();
  // ReminderAutoStop.attachOnce();

  await adhanScheduler.requestBatteryOptimizationExemption();

  runApp(const IslamicApp());
}
