import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/adhan_settings_model.dart';

abstract class AdhanSettingsLocalDataSource {
  Future<AdhanSettingsModel> getSettings();

  Future<void> saveSettings(
      AdhanSettingsModel settings,
      );

  Future<void> setPrayerEnabled({
    required int prayerIndex,
    required bool enabled,
  });
}

class AdhanSettingsLocalDataSourceImpl
    implements AdhanSettingsLocalDataSource {
  AdhanSettingsLocalDataSourceImpl({
    required SharedPreferences prefs,
  }) : _prefs = prefs;

  final SharedPreferences _prefs;

  static const String _key = 'adhan_settings';

  // ============================================================
  // GET SETTINGS
  // ============================================================

  @override
  Future<AdhanSettingsModel> getSettings() async {
    final saved = _prefs.getStringList(_key);

    debugPrint(
      '🔍 [AdhanSettings] getSettings()',
    );

    debugPrint(
      '🔑 key = $_key',
    );

    debugPrint(
      '💾 saved raw = $saved',
    );

    if (saved == null || saved.length != 6) {
      final defaults =
      AdhanSettingsModel.defaults();

      debugPrint(
        '⚠️ No valid saved settings → using DEFAULTS',
      );

      debugPrint(
        '🌅 Fajr = ${defaults.fajr}',
      );

      debugPrint(
        '🌄 Sunrise = ${defaults.sunrise}',
      );

      debugPrint(
        '☀️ Dhuhr = ${defaults.dhuhr}',
      );

      debugPrint(
        '🌤️ Asr = ${defaults.asr}',
      );

      debugPrint(
        '🌇 Maghrib = ${defaults.maghrib}',
      );

      debugPrint(
        '🌙 Isha = ${defaults.isha}',
      );

      return defaults;
    }

    final settings = AdhanSettingsModel(
      fajr: saved[0] == 'true',
      sunrise: saved[1] == 'true',
      dhuhr: saved[2] == 'true',
      asr: saved[3] == 'true',
      maghrib: saved[4] == 'true',
      isha: saved[5] == 'true',
    );

    debugPrint(
      '✅ Saved settings loaded:',
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

    return settings;
  }

  // ============================================================
  // SAVE SETTINGS
  // ============================================================

  @override
  Future<void> saveSettings(
      AdhanSettingsModel settings,
      ) async {
    final values = [
      settings.fajr.toString(),
      settings.sunrise.toString(),
      settings.dhuhr.toString(),
      settings.asr.toString(),
      settings.maghrib.toString(),
      settings.isha.toString(),
    ];

    debugPrint(
      '💾 [AdhanSettings] saveSettings()',
    );

    debugPrint(
      '📦 saving values = $values',
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

    final result = await _prefs.setStringList(
      _key,
      values,
    );

    debugPrint(
      '✅ SharedPreferences save result = $result',
    );

    final savedAfterWrite =
    _prefs.getStringList(_key);

    debugPrint(
      '🔎 value after save = $savedAfterWrite',
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
      '🔄 [AdhanSettings] setPrayerEnabled()',
    );

    debugPrint(
      '📌 prayerIndex = $prayerIndex',
    );

    debugPrint(
      '📌 enabled = $enabled',
    );

    final current = await getSettings();

    debugPrint(
      '📋 Current settings loaded before update',
    );

    final updated = switch (prayerIndex) {
      0 => current.copyWith(
        fajr: enabled,
      ),
      1 => current.copyWith(
        sunrise: enabled,
      ),
      2 => current.copyWith(
        dhuhr: enabled,
      ),
      3 => current.copyWith(
        asr: enabled,
      ),
      4 => current.copyWith(
        maghrib: enabled,
      ),
      5 => current.copyWith(
        isha: enabled,
      ),
      _ => current,
    };

    debugPrint(
      '🆕 Updated settings:',
    );

    debugPrint(
      '   Fajr    = ${updated.fajr}',
    );

    debugPrint(
      '   Sunrise = ${updated.sunrise}',
    );

    debugPrint(
      '   Dhuhr   = ${updated.dhuhr}',
    );

    debugPrint(
      '   Asr     = ${updated.asr}',
    );

    debugPrint(
      '   Maghrib = ${updated.maghrib}',
    );

    debugPrint(
      '   Isha    = ${updated.isha}',
    );

    await saveSettings(
      AdhanSettingsModel.fromEntity(updated),
    );

    debugPrint(
      '✅ Prayer setting updated successfully',
    );
  }
}