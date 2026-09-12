import '../../domain/entities/iqama_settings_entity.dart';

class IqamaSettingsModel extends IqamaSettingsEntity {
  const IqamaSettingsModel({
    required super.fajr,
    required super.sunrise,
    required super.dhuhr,
    required super.asr,
    required super.maghrib,
    required super.isha,
  });

  factory IqamaSettingsModel.fromEntity(
      IqamaSettingsEntity entity,
      ) {
    return IqamaSettingsModel(
      fajr: entity.fajr,
      sunrise: entity.sunrise,
      dhuhr: entity.dhuhr,
      asr: entity.asr,
      maghrib: entity.maghrib,
      isha: entity.isha,
    );
  }

  factory IqamaSettingsModel.defaults() {
    return const IqamaSettingsModel(
      fajr: 15,
      sunrise: 15,
      dhuhr: 15,
      asr: 15,
      maghrib: 15,
      isha: 15,
    );
  }
}