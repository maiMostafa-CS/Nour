import 'package:flutter/foundation.dart';

import '../ datasources/adhan_settings_local_data_source.dart';
import '../../domain/repositories/ adhan_settings_repository.dart';
import '../../domain/entities/adhan_settings_entity.dart';
import '../models/adhan_settings_model.dart';

class AdhanSettingsRepositoryImpl
    implements AdhanSettingsRepository {
  AdhanSettingsRepositoryImpl({
    required AdhanSettingsLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final AdhanSettingsLocalDataSource _localDataSource;

  // ============================================================
  // GET SETTINGS
  // ============================================================

  @override
  Future<AdhanSettingsEntity> getSettings() async {
    debugPrint(
      '📥 [Repository] getSettings() START',
    );

    final settings =
    await _localDataSource.getSettings();

    debugPrint(
      '📥 [Repository] Settings received:',
    );

    debugPrint(
      '   Fajr    = ${settings.fajr}',
    );

    debugPrint(
      '   Sunrise = ${settings.sunrise}',
    );

    debugPrint(
      '   Dhuhr   = ${settings.dhuhr}',
    );

    debugPrint(
      '   Asr     = ${settings.asr}',
    );

    debugPrint(
      '   Maghrib = ${settings.maghrib}',
    );

    debugPrint(
      '   Isha    = ${settings.isha}',
    );

    debugPrint(
      '📥 [Repository] getSettings() END',
    );

    return settings;
  }

  // ============================================================
  // SAVE SETTINGS
  // ============================================================

  @override
  Future<void> saveSettings(
      AdhanSettingsEntity settings,
      ) async {
    debugPrint(
      '💾 [Repository] saveSettings() START',
    );

    debugPrint(
      '   Fajr    = ${settings.fajr}',
    );

    debugPrint(
      '   Sunrise = ${settings.sunrise}',
    );

    debugPrint(
      '   Dhuhr   = ${settings.dhuhr}',
    );

    debugPrint(
      '   Asr     = ${settings.asr}',
    );

    debugPrint(
      '   Maghrib = ${settings.maghrib}',
    );

    debugPrint(
      '   Isha    = ${settings.isha}',
    );

    await _localDataSource.saveSettings(
      AdhanSettingsModel.fromEntity(settings),
    );

    debugPrint(
      '✅ [Repository] saveSettings() DONE',
    );
  }

  // ============================================================
  // SET ONE PRAYER
  // ============================================================

  @override
  Future<void> setPrayerEnabled({
    required int prayerIndex,
    required bool enabled,
  }) async {
    debugPrint(
      '🔄 [Repository] setPrayerEnabled()',
    );

    debugPrint(
      '   prayerIndex = $prayerIndex',
    );

    debugPrint(
      '   enabled = $enabled',
    );

    await _localDataSource.setPrayerEnabled(
      prayerIndex: prayerIndex,
      enabled: enabled,
    );

    debugPrint(
      '✅ [Repository] setPrayerEnabled() DONE',
    );
  }
}