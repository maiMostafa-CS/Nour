import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/iqama_settings_model.dart';

abstract class IqamaSettingsLocalDataSource {
  Future<IqamaSettingsModel> getSettings();

  Future<void> saveSettings(
      IqamaSettingsModel settings,
      );

  Future<void> setPrayerMinutes({
    required int prayerIndex,
    required int minutes,
  });
}

class IqamaSettingsLocalDataSourceImpl
    implements IqamaSettingsLocalDataSource {
  IqamaSettingsLocalDataSourceImpl({
    required SharedPreferences prefs,
  }) : _prefs = prefs;

  final SharedPreferences _prefs;

  static const String _key = 'iqama_settings';

  @override
  Future<IqamaSettingsModel> getSettings() async {
    debugPrint('🔍 [IqamaSettings] getSettings()');
    debugPrint('🔑 key = $_key');

    final saved = _prefs.getStringList(_key);

    debugPrint('💾 saved raw = $saved');

    if (saved == null || saved.length != 6) {
      debugPrint(
        '⚠️ No valid saved settings → using defaults',
      );

      return IqamaSettingsModel.defaults();
    }

    final settings = IqamaSettingsModel(
      fajr: int.tryParse(saved[0]) ?? 15,
      sunrise: int.tryParse(saved[1]) ?? 15,
      dhuhr: int.tryParse(saved[2]) ?? 15,
      asr: int.tryParse(saved[3]) ?? 15,
      maghrib: int.tryParse(saved[4]) ?? 15,
      isha: int.tryParse(saved[5]) ?? 15,
    );

    debugPrint('✅ Saved Iqama settings loaded:');
    debugPrint('   Fajr    = ${settings.fajr}');
    debugPrint('   Sunrise = ${settings.sunrise}');
    debugPrint('   Dhuhr   = ${settings.dhuhr}');
    debugPrint('   Asr     = ${settings.asr}');
    debugPrint('   Maghrib = ${settings.maghrib}');
    debugPrint('   Isha    = ${settings.isha}');

    return settings;
  }

  @override
  Future<void> saveSettings(
      IqamaSettingsModel settings,
      ) async {
    debugPrint('💾 [IqamaSettings] saveSettings()');

    final values = [
      settings.fajr.toString(),
      settings.sunrise.toString(),
      settings.dhuhr.toString(),
      settings.asr.toString(),
      settings.maghrib.toString(),
      settings.isha.toString(),
    ];

    debugPrint('📦 saving values = $values');

    final result = await _prefs.setStringList(
      _key,
      values,
    );

    debugPrint(
      '✅ SharedPreferences save result = $result',
    );

    debugPrint(
      '🔎 value after save = ${_prefs.getStringList(_key)}',
    );
  }

  @override
  Future<void> setPrayerMinutes({
    required int prayerIndex,
    required int minutes,
  }) async {
    final current = await getSettings();

    final safeMinutes = minutes.clamp(1, 60);

    final updated = switch (prayerIndex) {
      0 => current.copyWith(fajr: safeMinutes),
      1 => current.copyWith(sunrise: safeMinutes),
      2 => current.copyWith(dhuhr: safeMinutes),
      3 => current.copyWith(asr: safeMinutes),
      4 => current.copyWith(maghrib: safeMinutes),
      5 => current.copyWith(isha: safeMinutes),
      _ => current,
    };

    debugPrint(
      '🔄 [IqamaSettings] '
          'index=$prayerIndex | '
          'minutes=$safeMinutes',
    );

    await saveSettings(
      IqamaSettingsModel.fromEntity(updated),
    );
  }
}