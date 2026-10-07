import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../features/adhan_settings/data/datasources/adhan_settings_local_data_source.dart';
import '../../../../../features/adhan_settings/data/repositories/adhan_settings_repository_impl.dart';
import '../../../../../features/adhan_sound/data/datasources/adhan_local_data_source.dart';
import '../../../../../features/iqama_setting/data/datasources/iqama_settings_local_data_source.dart';
import '../../../../../features/iqama_setting/data/repositories/iqama_settings_repository_impl.dart';
import '../../../../../../../features/prayer_times/data/datasources/prayer_local_data_source.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../adhan_scheduler_service.dart';
import '../config/prayer_scheduler_config.dart';
import '../data/datasources/prayer_notification_local_data_source_impl.dart';
import '../notifications/countdown_notification_service.dart';
import '../services/adhan_asset_provider.dart';
import '../utils/prayer_alarm_logger.dart';

// ============================================================
// COUNTDOWN CALLBACK
// ============================================================

@pragma('vm:entry-point')
Future<void> updatePrayerNotificationCountdownCallback() async {
  WidgetsFlutterBinding.ensureInitialized();

  prayerSchedulerLog(
    '🚀🚀🚀 BACKGROUND COUNTDOWN CALLBACK STARTED',
  );

  try {
    await CountdownNotificationService.showNextPrayerCountdown();

    prayerSchedulerLog(
      '✅ BACKGROUND CALLBACK FINISHED',
    );
  } catch (e, stackTrace) {
    prayerSchedulerLog(
      '❌ BACKGROUND CALLBACK FAILED: $e',
    );
    prayerSchedulerLog('STACKTRACE: $stackTrace');
  }
}

// ============================================================
// MAINTENANCE CALLBACK
// ============================================================

@pragma('vm:entry-point')
Future<void> prayerScheduleMaintenanceCallback() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    tz.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (_) {}
    await PrayerAlarmLogger.initTimezone();

    final prefs = await SharedPreferences.getInstance();

    final latitude = prefs.getDouble(prayerLastLatitudePrefsKey);
    final longitude = prefs.getDouble(prayerLastLongitudePrefsKey);

    if (latitude == null || longitude == null) return;

    // Background isolate: alarm plugin is not initialized here yet.
    await AdhanSchedulerService.ensureAlarmInitialized();

    final adhanLocalDataSource = AdhanLocalDataSourceImpl(
      prefs: prefs,
    );

    final dataSource = PrayerNotificationLocalDataSourceImpl(
      prayerCalculator: PrayerLocalDataSourceImpl(),
      adhanSettingsRepository: AdhanSettingsRepositoryImpl(
        localDataSource: AdhanSettingsLocalDataSourceImpl(
          prefs: prefs,
        ),
      ),
      iqamaSettingsRepository: IqamaSettingsRepositoryImpl(
        localDataSource: IqamaSettingsLocalDataSourceImpl(
          prefs: prefs,
        ),
      ),
      adhanLocalDataSource: adhanLocalDataSource,
      adhanAssetProvider: AdhanAssetProvider(
        localDataSource: adhanLocalDataSource,
      ),
    );

    await dataSource.ensureWindowScheduled(
      latitude: latitude,
      longitude: longitude,
      days: 4,
    );
  } catch (e, stackTrace) {
    prayerSchedulerLog('❌ Prayer maintenance failed: $e');
    prayerSchedulerLog('STACKTRACE: $stackTrace');
  }
}