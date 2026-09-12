import '../entities/adhan_settings_entity.dart';

abstract class AdhanSettingsRepository {
  Future<AdhanSettingsEntity> getSettings();

  Future<void> saveSettings(
      AdhanSettingsEntity settings,
      );

  Future<void> setPrayerEnabled({
    required int prayerIndex,
    required bool enabled,
  });
}