import 'package:flutter/foundation.dart';

import '../datasources/iqama_settings_local_data_source.dart';
import '../../domain/entities/iqama_settings_entity.dart';
import '../../domain/repositories/iqama_settings_repository.dart';
import '../models/iqama_settings_model.dart';

class IqamaSettingsRepositoryImpl
    implements IqamaSettingsRepository {
  IqamaSettingsRepositoryImpl({
    required IqamaSettingsLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final IqamaSettingsLocalDataSource _localDataSource;

  @override
  Future<IqamaSettingsEntity> getSettings() async {
    debugPrint(
      '📥 [IqamaRepository] getSettings() START',
    );

    final settings =
    await _localDataSource.getSettings();

    debugPrint(
      '📥 [IqamaRepository] '
          'Fajr=${settings.fajr} | '
          'Sunrise=${settings.sunrise} | '
          'Dhuhr=${settings.dhuhr} | '
          'Asr=${settings.asr} | '
          'Maghrib=${settings.maghrib} | '
          'Isha=${settings.isha}',
    );

    return settings;
  }

  @override
  Future<void> saveSettings(
      IqamaSettingsEntity settings,
      ) {
    return _localDataSource.saveSettings(
      IqamaSettingsModel.fromEntity(settings),
    );
  }

  @override
  Future<void> setPrayerMinutes({
    required int prayerIndex,
    required int minutes,
  }) {
    return _localDataSource.setPrayerMinutes(
      prayerIndex: prayerIndex,
      minutes: minutes,
    );
  }
}