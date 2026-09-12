import '../entities/iqama_settings_entity.dart';

abstract class IqamaSettingsRepository {
  Future<IqamaSettingsEntity> getSettings();

  Future<void> saveSettings(
      IqamaSettingsEntity settings,
      );

  Future<void> setPrayerMinutes({
    required int prayerIndex,
    required int minutes,
  });
}