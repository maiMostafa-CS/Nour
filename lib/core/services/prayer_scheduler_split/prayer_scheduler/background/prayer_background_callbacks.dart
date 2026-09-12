import 'package:flutter/widgets.dart';

import '../../../../../features/adhan/data/datasources/adhan_local_data_source.dart';
import '../../../../../features/adhan_settings/data/ datasources/adhan_settings_local_data_source.dart';
import '../../../../../features/adhan_settings/data/repositories/adhan_settings_repository_impl.dart';
import '../../../../../features/iqama_setting/data/datasources/iqama_settings_local_data_source.dart';
import '../../../../../features/iqama_setting/data/repositories/iqama_settings_repository_impl.dart';
import '../notifications/countdown_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../../features/prayer_times/data/datasources/prayer_local_data_source.dart';
import '../data/datasources/prayer_notification_local_data_source_impl.dart';
import '../config/prayer_scheduler_config.dart';

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


/// Background maintenance callback. Keeps a rolling prayer window alive even
/// when the user does not open the application.
@pragma('vm:entry-point')
Future<void> prayerScheduleMaintenanceCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble(prayerLastLatitudePrefsKey);
    final longitude = prefs.getDouble(prayerLastLongitudePrefsKey);
    if (latitude == null || longitude == null) return;

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

      adhanLocalDataSource: AdhanLocalDataSourceImpl(
        prefs: prefs,
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
