import '../entities/iqama_settings_entity.dart';
import '../repositories/iqama_settings_repository.dart';

class UpdateIqamaSetting {
  final IqamaSettingsRepository repository;

  const UpdateIqamaSetting({
    required this.repository,
  });

  Future<IqamaSettingsEntity> call({
    required IqamaSettingsEntity currentSettings,
    required int prayerIndex,
    required int minutes,
  }) async {
    final safeMinutes = minutes.clamp(1, 60);

    final updatedSettings = switch (prayerIndex) {
      0 => currentSettings.copyWith(
        fajr: safeMinutes,
      ),
      1 => currentSettings.copyWith(
        sunrise: safeMinutes,
      ),
      2 => currentSettings.copyWith(
        dhuhr: safeMinutes,
      ),
      3 => currentSettings.copyWith(
        asr: safeMinutes,
      ),
      4 => currentSettings.copyWith(
        maghrib: safeMinutes,
      ),
      5 => currentSettings.copyWith(
        isha: safeMinutes,
      ),
      _ => currentSettings,
    };

    await repository.setPrayerMinutes(
      prayerIndex: prayerIndex,
      minutes: safeMinutes,
    );

    return updatedSettings;
  }
}