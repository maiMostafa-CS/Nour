import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app.dart';
import 'core/services/alarm_cleanup/orphan_alarm_cleaner.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/adhan_scheduler_service.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/notifications/countdown_notification_service.dart';
import 'core/services/unlock_card.dart';
import 'features/khatma/domain/useCase/get_current_khatma_ayah.dart';
import 'features/khatma/domain/useCase/get_khatma_weekly_report.dart';
import 'features/khatma/domain/useCase/markCurrent_ayahAs_read.dart';
import 'features/khatma/services/khatma_unlock_service.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  // 1️⃣ سجّل التبعيات
  await configureDependencies();
  await Alarm.init();

  // 2️⃣ نظّف المنبهات اليتيمة BEFORE runApp
  if (Platform.isAndroid) {
    try {
      final cleaner = sl<OrphanAlarmCleaner>();
      await cleaner.cleanOrphans();
    } catch (e, st) {
      debugPrint('❌ [main] cleanOrphans failed: $e');
      debugPrint('$st');
      // متوقفش التطبيق لو التنظيف فشل
    }
  }

  // 3️⃣ سجّل Khatma handler
  if (Platform.isAndroid) {
    KhatmaUnlockSyncService.setKhatmaReadHandler(_onNativeKhatmaRead);
  }

  // 4️⃣ شغّل التطبيق
  runApp(const IslamicApp());

  // 5️⃣ بعد ما التطبيق يظهر — نفّذ الـ setup
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _initializeKhatmaUnlock();
    await _backgroundSetup();
  });
}

Future<void> _initializeKhatmaUnlock() async {
  if (!Platform.isAndroid) {
    return;
  }

  try {
    await _syncKhatmaUnlockAyah();
    await _restoreUnlockCard();

    debugPrint('✅ KHATMA UNLOCK: initialization completed');
  } catch (e, stackTrace) {
    debugPrint('❌ KHATMA UNLOCK INITIALIZATION FAILED: $e');
    debugPrint('$stackTrace');
  }
}

Future<void> _restoreUnlockCard() async {
  if (!Platform.isAndroid) return;
  if (await UnlockCard.isEnabled() && await UnlockCard.hasOverlayPermission()) {
    await UnlockCard.start();
  }
}

Future<void> _backgroundSetup() async {
  final sw = Stopwatch()..start();

  try {
    // ============================================================
    // Adhan Scheduler
    // ============================================================

    final adhanScheduler = AdhanSchedulerService();

    await adhanScheduler.initialize();

    debugPrint(
      '⏱️ adhanScheduler.initialize: ${sw.elapsedMilliseconds}ms',
    );

    sw.reset();

    // ============================================================
    // Exact Alarm Permission
    // ============================================================

    await checkAndroidScheduleExactAlarmPermission();

    debugPrint(
      '⏱️ permission: ${sw.elapsedMilliseconds}ms',
    );

    sw.reset();

    // ============================================================
    // Battery Optimization
    // ============================================================

    await adhanScheduler.requestBatteryOptimizationExemption();

    debugPrint(
      '⏱️ battery: ${sw.elapsedMilliseconds}ms',
    );
  } catch (e, stackTrace) {
    debugPrint('❌ Background setup failed: $e');
    debugPrint('$stackTrace');
  }
}

Future<void> checkAndroidScheduleExactAlarmPermission() async {
  final status = await Permission.scheduleExactAlarm.status;

  prayerSchedulerLog(
    '📋 Schedule exact alarm permission: $status',
  );

  if (status.isDenied) {
    final result = await Permission.scheduleExactAlarm.request();

    prayerSchedulerLog(
      '📋 Schedule exact alarm permission after request: $result',
    );
  }
}

Future<void> _syncKhatmaUnlockAyah() async {
  if (!Platform.isAndroid) {
    return;
  }

  try {
    final getCurrentKhatmaAyah = sl<GetCurrentKhatmaAyah>();

    final ayah = await getCurrentKhatmaAyah();

    if (ayah == null) {
      debugPrint('🌿 KHATMA UNLOCK: no current ayah');
      return;
    }

    await KhatmaUnlockSyncService.saveCurrentAyah(ayah);

    debugPrint(
      '✅ KHATMA UNLOCK: synced '
          'global=${ayah.globalNumber} '
          'surah=${ayah.surahName} '
          'ayah=${ayah.ayahNumber} '
          'page=${ayah.pageNumber}',
    );
  } catch (e, stackTrace) {
    debugPrint('❌ KHATMA UNLOCK SYNC FAILED: $e');
    debugPrint('$stackTrace');
  }
}

Future<void> _onNativeKhatmaRead() async {
  try {
    debugPrint('📖 KHATMA: Native requested read');

    // 1. Mark current ayah as read
    final markCurrentAyahAsRead = sl<MarkCurrentAyahAsRead>();
    final progress = await markCurrentAyahAsRead();

    debugPrint(
      '✅ KHATMA: '
          'currentAyah=${progress.currentAyah}, '
          'readAyahs=${progress.readAyahs}',
    );

    // 2. Get weekly report
    final getKhatmaWeeklyReport = sl<GetKhatmaWeeklyReport>();
    final report = await getKhatmaWeeklyReport();

    debugPrint(
      '📊 KHATMA WEEKLY: '
          'total=${report.totalAyahs}, '
          'currentWeek=${report.currentWeekAyahs}, '
          'week=${report.weekNumber}',
    );

    // 3. Send weekly report to Android
    await KhatmaUnlockSyncService.saveWeeklyReport(
      totalAyahs: report.totalAyahs,
      currentWeekAyahs: report.currentWeekAyahs,
      weekNumber: report.weekNumber,
    );

    debugPrint('✅ KHATMA WEEKLY: report synced to Android');

    // 4. Sync next ayah to Android
    await _syncKhatmaUnlockAyah();

    debugPrint('✅ KHATMA: New ayah synced');
  } catch (e, stackTrace) {
    debugPrint('❌ KHATMA READ FAILED: $e');
    debugPrint('$stackTrace');
  }
}