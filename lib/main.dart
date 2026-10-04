import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app.dart';
import 'core/services/alarm_cleanup/orphan_alarm_cleaner.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/adhan_scheduler_service.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/notifications/countdown_notification_service.dart';
import 'core/services/unlock_card.dart';
import 'features/khatma/data/datasources/khatma_local_data_source.dart';
import 'features/khatma/domain/entities/khatma_progress.dart';
import 'features/khatma/domain/useCase/get_current_khatma_ayah.dart';
import 'features/khatma/domain/useCase/get_khatma_weekly_report.dart';
import 'features/khatma/domain/useCase/markCurrent_ayahAs_read.dart';
import 'features/khatma/services/khatma_ayah_resolver.dart';
import 'features/khatma/services/khatma_controller.dart';
import 'features/khatma/services/khatma_unlock_service.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  tz.initializeTimeZones();
  await configureDependencies();

  if (Platform.isAndroid) {
    await _initializeAndroid();
    KhatmaUnlockSyncService.setKhatmaReadHandler(_onNativeKhatmaRead);
    await _processPendingKhatmaRead();

    _setupAdhanStopHandler();
    await _processPendingAdhanStop();
  }

  runApp(const IslamicApp());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _runPostFrameSetup();
  });
}

@pragma('vm:entry-point')
void backgroundMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🚀 KHATMA BACKGROUND: engine started');
  _setupAdhanStopHandler();
 await _processPendingAdhanStop();

  KhatmaUnlockSyncService.setKhatmaReadHandler(() async {
    debugPrint('📖 KHATMA BACKGROUND: read requested');

    try {
      final prefs = await SharedPreferences.getInstance();
      final dataSource = KhatmaLocalDataSourceImpl(prefs);

      // ============================================================
      // 1. علّم الآية كمقروءة
      // ============================================================
      final progress = await dataSource.markCurrentAyahAsRead();

      debugPrint(
        '✅ KHATMA BACKGROUND: '
            'currentAyah=${progress.currentAyah}, '
            'readAyahs=${progress.readAyahs}',
      );

      // ============================================================
      // 2. اجلب التقرير الأسبوعي وزامنه مع Native
      // ============================================================
      final report = await dataSource.getWeeklyReport();

      await KhatmaUnlockSyncService.saveWeeklyReport(
        totalAyahs: report.totalAyahs,
        currentWeekAyahs: report.currentWeekAyahs,
        weekNumber: report.weekNumber,
      );

      debugPrint('📊 KHATMA BACKGROUND: weekly report synced');

      // ============================================================
      // 3. ✅ زامن الآية الجديدة مع Native
      // ============================================================
      final nextAyahNumber = progress.currentAyah;
      debugPrint('📖 KHATMA BACKGROUND: resolving ayah $nextAyahNumber');

      final ayah = KhatmaAyahResolver.resolve(nextAyahNumber);

      await KhatmaUnlockSyncService.saveCurrentAyah(
        KhatmaUnlockAyah(
          globalNumber: ayah.globalNumber,
          surahNumber: ayah.surahNumber,
          ayahNumber: ayah.ayahNumber,
          surahName: ayah.surahName,
          text: ayah.text,
          pageNumber: ayah.pageNumber,
        ),
      );

      debugPrint(
        '✅ KHATMA BACKGROUND: new ayah synced '
            '(global=${ayah.globalNumber}, '
            'surah=${ayah.surahName}, '
            'ayah=${ayah.ayahNumber})',
      );

    } catch (e, stackTrace) {
      debugPrint('❌ KHATMA BACKGROUND FAILED: $e');
      debugPrint('$stackTrace');
    } finally {
      await KhatmaUnlockSyncService.clearPendingRead();
    }
  });
}

Future<void> _stopAdhanForCall() async {
  try {
    final alarms = await Alarm.getAlarms();
    var stopped = 0;

    for (final alarm in alarms) {
      if (alarm.payload == 'adhan' || alarm.payload == 'iqama') {
        await Alarm.stop(alarm.id);
        stopped++;
        debugPrint('🔇 Stopped alarm id=${alarm.id} payload=${alarm.payload}');
      }
    }

    debugPrint('✅ ADHAN: $stopped alarm(s) stopped');
  } catch (e, stackTrace) {
    debugPrint('❌ ADHAN: stop failed: $e');
    debugPrint('$stackTrace');
  }
}


void _setupAdhanStopHandler() {
  const adhanChannel = MethodChannel('com.example.islamic_app/adhan');

  adhanChannel.setMethodCallHandler((call) async {
    if (call.method == 'stopAdhan') {
      debugPrint('📞 KHATMA: stopAdhan requested');
      await _stopAdhanForCall();
    }
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

    // ==========================================================
    // 3. Start the card
    // ==========================================================

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
// Process pending Khatma read
// ================================================================

Future<void> _processPendingKhatmaRead() async {
  if (!Platform.isAndroid) {
    return;
  }

  try {
    final hasPending =
    await KhatmaUnlockSyncService.hasPendingRead();

    debugPrint(
      '🔍 KHATMA: hasPendingRead = $hasPending',
    );

    if (!hasPending) {
      return;
    }

    debugPrint(
      '📖 KHATMA: Processing pending read...',
    );

    // Same logic as _onNativeKhatmaRead
    await _onNativeKhatmaRead();

    debugPrint(
      '✅ KHATMA: Pending read processed',
    );
  } catch (e, stackTrace) {
    debugPrint(
      '❌ KHATMA: Pending read failed: $e',
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
    KhatmaController.update(progress);
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

// ------------------------------------------------------------
// 5. Clear the pending_read flag (important to avoid duplicates)
// ------------------------------------------------------------
  } catch (e, stackTrace) {
    debugPrint(
      '❌ KHATMA READ FAILED: $e',
    );

    debugPrint('$stackTrace');
  }finally {
    await KhatmaUnlockSyncService.clearPendingRead();
    debugPrint('🧹 KHATMA: pending_read cleared');
  }
}
Future<void> _processPendingAdhanStop() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final requested = prefs.getBool('stop_adhan_requested') ?? false;

    if (!requested) return;

    debugPrint('📞 ADHAN: processing pending stop');

    await _stopAdhanForCall();

    await prefs.setBool('stop_adhan_requested', false);
  } catch (e, stackTrace) {
    debugPrint('❌ ADHAN: pending stop failed: $e');
    debugPrint('$stackTrace');
  }
}