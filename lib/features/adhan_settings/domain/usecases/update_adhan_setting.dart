import '../entities/adhan_settings_entity.dart';
import '../repositories/adhan_settings_repository.dart';

class UpdateAdhanSetting {
  final AdhanSettingsRepository repository;

  const UpdateAdhanSetting({
    required this.repository,
  });

  Future<AdhanSettingsEntity> call({
    required AdhanSettingsEntity currentSettings,
    required int prayerIndex,
    required bool enabled,
  }) async {
    final updatedSettings = switch (prayerIndex) {
      0 => currentSettings.copyWith(
        fajr: enabled,
      ),
      1 => currentSettings.copyWith(
        sunrise: enabled,
      ),
      2 => currentSettings.copyWith(
        dhuhr: enabled,
      ),
      3 => currentSettings.copyWith(
        asr: enabled,
      ),
      4 => currentSettings.copyWith(
        maghrib: enabled,
      ),
      5 => currentSettings.copyWith(
        isha: enabled,
      ),
      _ => currentSettings,
    };

    await repository.saveSettings(updatedSettings);

    return updatedSettings;
  }
}