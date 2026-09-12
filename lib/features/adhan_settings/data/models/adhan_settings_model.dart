import '../../domain/entities/adhan_settings_entity.dart';

class AdhanSettingsModel extends AdhanSettingsEntity {
  const AdhanSettingsModel({
    required super.fajr,
    required super.sunrise,
    required super.dhuhr,
    required super.asr,
    required super.maghrib,
    required super.isha,
  });

  factory AdhanSettingsModel.fromEntity(
      AdhanSettingsEntity entity,
      ) {
    return AdhanSettingsModel(
      fajr: entity.fajr,
      sunrise: entity.sunrise,
      dhuhr: entity.dhuhr,
      asr: entity.asr,
      maghrib: entity.maghrib,
      isha: entity.isha,
    );
  }

  factory AdhanSettingsModel.defaults() {
    return const AdhanSettingsModel(
      fajr: true,
      sunrise: false,
      dhuhr: true,
      asr: true,
      maghrib: true,
      isha: true,
    );
  }
}