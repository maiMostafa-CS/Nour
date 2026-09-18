import 'package:azkary/azkary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quran_kit/kit.dart';

import 'app.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/adhan_scheduler_service.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/notifications/countdown_notification_service.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/scheduler/reminder_scheduler.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  runApp(const IslamicApp());
  // await Azkary.initialize();
  await QuranKit.initialize(
    QuranKitConfig(
      fontBaseUrl: 'https://YOUR-DOMAIN.com/qfc4',

      enableAudio: true,
      enableTafsir: true,
      enableSearch: true,
      enableWordByWord: true,
      enableAsbabNuzul: true,

      defaultReciterIndex: 0,
      defaultTafsirId: 'al-tabari',
      defaultEditionId: 'ar-uthmani',
      defaultQiraa: 'hafs',

      showTajweed: true,
    ),
  );  SchedulerBinding.instance.addPostFrameCallback((_) async {
    await _backgroundSetup();
  });
}

Future<void> _backgroundSetup() async {
  final sw = Stopwatch()..start();

  try {
    final adhanScheduler = AdhanSchedulerService();
    await adhanScheduler.initialize();
    debugPrint('⏱️ adhanScheduler.initialize: ${sw.elapsedMilliseconds}ms');
    sw.reset();

    await checkAndroidScheduleExactAlarmPermission();
    debugPrint('⏱️ permission: ${sw.elapsedMilliseconds}ms');
    sw.reset();

    await adhanScheduler.requestBatteryOptimizationExemption();
    debugPrint('⏱️ battery: ${sw.elapsedMilliseconds}ms');
  } catch (e, stackTrace) {
    debugPrint('❌ Background setup failed: $e');
    debugPrint('$stackTrace');
  }
}

Future<void> checkAndroidScheduleExactAlarmPermission() async {
  final status = await Permission.scheduleExactAlarm.status;
  prayerSchedulerLog('📋 Schedule exact alarm permission: $status');

  if (status.isDenied) {
    final result = await Permission.scheduleExactAlarm.request();
    prayerSchedulerLog('📋 Schedule exact alarm permission after request: $result');
  }
}