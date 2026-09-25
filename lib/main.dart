import 'dart:io';

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

// ============================================================
// Timezone
// ============================================================

  tz.initializeTimeZones();

// ============================================================
// Dependency Injection
// ============================================================

  await configureDependencies();

// ============================================================
// Android-only initialization
// ============================================================

  if (Platform.isAndroid) {
    await _initializeAndroid();
  }

// ============================================================
// Khatma native callback
// ============================================================

  if (Platform.isAndroid) {
    KhatmaUnlockSyncService.setKhatmaReadHandler(
      _onNativeKhatmaRead,
    );
  }

// ============================================================
// Start Flutter application
// ============================================================

  runApp(const IslamicApp());

// ============================================================
// Background setup after first frame
// ============================================================

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _runPostFrameSetup();
  });
}

// ================================================================
// Android initialization
// ================================================================

Future<void> _initializeAndroid() async {
  try {
// ------------------------------------------------------------
// Alarm initialization is intentionally NOT done here.
//
// AdhanSchedulerService owns Alarm.init().
// This prevents duplicate Alarm.init() calls.
// ------------------------------------------------------------

    await _cleanOrphanAlarms();
  } catch (e, stackTrace) {
    debugPrint(
      '❌ [main] Android initialization failed: $e',
    );

    debugPrint('$stackTrace');
  }
}

// ================================================================
// Orphan alarm cleanup
// ================================================================

Future<void> _cleanOrphanAlarms() async {
  try {
    final cleaner = sl<OrphanAlarmCleaner>();

    await cleaner.cleanOrphans();

    debugPrint(
      '✅ [main] Orphan alarms cleaned',
    );
  } catch (e, stackTrace) {
    debugPrint(
      '❌ [main] cleanOrphans failed: $e',
    );

    debugPrint('$stackTrace');
  }
}

// ================================================================
// Post-frame setup
// ================================================================

Future<void> _runPostFrameSetup() async {
// --------------------------------------------------------------
// Khatma
// --------------------------------------------------------------

  await _initializeKhatmaUnlock();

// --------------------------------------------------------------
// Prayer / Adhan background system
// --------------------------------------------------------------

  await _backgroundSetup();
}

// ================================================================
// Khatma initialization
// ================================================================

Future<void> _initializeKhatmaUnlock() async {
  if (!Platform.isAndroid) {
    return;
  }

  try {
    await _syncKhatmaUnlockAyah();

    await _restoreUnlockCard();

    debugPrint(
      '✅ KHATMA UNLOCK: initialization completed',
    );
  } catch (e, stackTrace) {
    debugPrint(
      '❌ KHATMA UNLOCK INITIALIZATION FAILED: $e',
    );

    debugPrint('$stackTrace');
  }
}

// ================================================================
// Restore unlock card
// ================================================================

Future<void> _restoreUnlockCard() async {
  if (!Platform.isAndroid) {
    return;
  }

  try {
    final enabled = await UnlockCard.isEnabled();

    if (!enabled) {
      debugPrint(
        'ℹ️ KHATMA UNLOCK: service disabled',
      );
      return;
    }

    final hasOverlayPermission = await UnlockCard.hasOverlayPermission();

    if (!hasOverlayPermission) {
      debugPrint(
        '⚠️ KHATMA UNLOCK: overlay permission missing',
      );
      return;
    }

    await UnlockCard.start();

    debugPrint(
      '✅ KHATMA UNLOCK: service restored',
    );
  } catch (e, stackTrace) {
    debugPrint(
      '❌ KHATMA UNLOCK RESTORE FAILED: $e',
    );

    debugPrint('$stackTrace');
  }
}

// ================================================================
// Background setup
// ================================================================

Future<void> _backgroundSetup() async {
  final stopwatch = Stopwatch()..start();

  try {
    debugPrint(
      '🚀 BACKGROUND SETUP: started',
    );

// ==========================================================
// Adhan Scheduler
// ==========================================================

    final adhanScheduler = AdhanSchedulerService();

    await adhanScheduler.initialize();

    debugPrint(
      '✅ ADHAN SCHEDULER INITIALIZED '
      '| ${stopwatch.elapsedMilliseconds}ms',
    );

    stopwatch
      ..reset()
      ..start();

// ==========================================================
// Exact Alarm Permission
// ==========================================================

    await checkAndroidScheduleExactAlarmPermission();

    debugPrint(
      '✅ EXACT ALARM PERMISSION CHECKED '
      '| ${stopwatch.elapsedMilliseconds}ms',
    );

    stopwatch
      ..reset()
      ..start();

// ==========================================================
// Battery Optimization
// ==========================================================

    await adhanScheduler.requestBatteryOptimizationExemption();

    debugPrint(
      '✅ BATTERY OPTIMIZATION CHECKED '
      '| ${stopwatch.elapsedMilliseconds}ms',
    );

    debugPrint(
      '🎉 BACKGROUND SETUP: completed',
    );
  } catch (e, stackTrace) {
    debugPrint(
      '❌ BACKGROUND SETUP FAILED: $e',
    );

    debugPrint('$stackTrace');
  } finally {
    stopwatch.stop();
  }
}

// ================================================================
// Exact alarm permission
// ================================================================

Future<void> checkAndroidScheduleExactAlarmPermission() async {
  if (!Platform.isAndroid) {
    return;
  }

  try {
    final status = await Permission.scheduleExactAlarm.status;

    prayerSchedulerLog(
      '📋 Schedule exact alarm permission: $status',
    );

    if (status.isGranted) {
      prayerSchedulerLog(
        '✅ Schedule exact alarm permission already granted',
      );

      return;
    }

    if (status.isDenied) {
      final result = await Permission.scheduleExactAlarm.request();

      prayerSchedulerLog(
        '📋 Schedule exact alarm permission after request: $result',
      );

      if (result.isGranted) {
        prayerSchedulerLog(
          '✅ Schedule exact alarm permission granted',
        );
      } else {
        prayerSchedulerLog(
          '⚠️ Schedule exact alarm permission NOT granted',
        );
      }

      return;
    }

    prayerSchedulerLog(
      '⚠️ Schedule exact alarm permission status: $status',
    );
  } catch (e, stackTrace) {
    prayerSchedulerLog(
      '❌ Exact alarm permission check failed: $e',
    );

    prayerSchedulerLog(
      'STACKTRACE: $stackTrace',
    );
  }
}

// ================================================================
// Sync current Khatma ayah
// ================================================================

Future<void> _syncKhatmaUnlockAyah() async {
  if (!Platform.isAndroid) {
    return;
  }

  try {
    final getCurrentKhatmaAyah = sl<GetCurrentKhatmaAyah>();

    final ayah = await getCurrentKhatmaAyah();

    if (ayah == null) {
      debugPrint(
        '🌿 KHATMA UNLOCK: no current ayah',
      );

      return;
    }

    await KhatmaUnlockSyncService.saveCurrentAyah(
      ayah,
    );

    debugPrint(
      '✅ KHATMA UNLOCK: synced '
      'global=${ayah.globalNumber} '
      'surah=${ayah.surahName} '
      'ayah=${ayah.ayahNumber} '
      'page=${ayah.pageNumber}',
    );
  } catch (e, stackTrace) {
    debugPrint(
      '❌ KHATMA UNLOCK SYNC FAILED: $e',
    );

    debugPrint('$stackTrace');
  }
}

// ================================================================
// Native Khatma read callback
// ================================================================

Future<void> _onNativeKhatmaRead() async {
  try {
    debugPrint(
      '📖 KHATMA: Native requested read',
    );

// ------------------------------------------------------------
// 1. Mark current ayah as read
// ------------------------------------------------------------

    final markCurrentAyahAsRead = sl<MarkCurrentAyahAsRead>();

    final progress = await markCurrentAyahAsRead();

    debugPrint(
      '✅ KHATMA: '
      'currentAyah=${progress.currentAyah}, '
      'readAyahs=${progress.readAyahs}',
    );

// ------------------------------------------------------------
// 2. Get weekly report
// ------------------------------------------------------------

    final getKhatmaWeeklyReport = sl<GetKhatmaWeeklyReport>();

    final report = await getKhatmaWeeklyReport();

    debugPrint(
      '📊 KHATMA WEEKLY: '
      'total=${report.totalAyahs}, '
      'currentWeek=${report.currentWeekAyahs}, '
      'week=${report.weekNumber}',
    );

// ------------------------------------------------------------
// 3. Sync weekly report with Android
// ------------------------------------------------------------

    await KhatmaUnlockSyncService.saveWeeklyReport(
      totalAyahs: report.totalAyahs,
      currentWeekAyahs: report.currentWeekAyahs,
      weekNumber: report.weekNumber,
    );

    debugPrint(
      '✅ KHATMA WEEKLY: report synced to Android',
    );

// ------------------------------------------------------------
// 4. Sync next ayah
// ------------------------------------------------------------

    await _syncKhatmaUnlockAyah();

    debugPrint(
      '✅ KHATMA: New ayah synced',
    );
  } catch (e, stackTrace) {
    debugPrint(
      '❌ KHATMA READ FAILED: $e',
    );

    debugPrint('$stackTrace');
  }
}
