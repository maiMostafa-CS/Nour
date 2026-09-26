// lib/features/tasbih/data/custom_dhikr_storage.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/tasbih_model.dart';

class CustomDhikrStorage {
  static const String _customKey = 'custom_adhkar';
  static const String _overridesKey = 'adhkar_overrides'; // ✨ جديد

  // ===== الأذكار المخصصة =====
  Future<List<TasbihDhikr>> loadCustomAdhkar() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_customKey) ?? [];
    return raw
        .map((e) => TasbihDhikr.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCustomAdhkar(List<TasbihDhikr> adhkar) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = adhkar
        .where((d) => d.isCustom)
        .map((d) => jsonEncode(d.toJson()))
        .toList();
    await prefs.setStringList(_customKey, raw);
  }

  // ===== تعديلات الأذكار الافتراضية =====
  /// يحفظ فقط الأذكار الافتراضية التي تم تعديل targetCount الخاص بها
  Future<void> saveModifiedDefaults(List<TasbihDhikr> allAdhkar) async {
    final prefs = await SharedPreferences.getInstance();
    final modified = <Map<String, dynamic>>[];

    // الأذكار الافتراضية المعرّفة في التطبيق
    // نمررها كنطاق للتحقق
    for (final dhikr in allAdhkar.where((d) => !d.isCustom)) {
      modified.add({
        'id': dhikr.id,
        'targetCount': dhikr.targetCount,
      });
    }

    final raw = modified.map((m) => jsonEncode(m)).toList();
    await prefs.setStringList(_overridesKey, raw);
  }

  /// يُرجع خريطة: id → targetCount للأذكار الافتراضية المعدّلة
  Future<Map<int, int>> loadOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_overridesKey) ?? [];
    final map = <int, int>{};
    for (final item in raw) {
      final json = jsonDecode(item) as Map<String, dynamic>;
      map[json['id'] as int] = json['targetCount'] as int;
    }
    return map;
  }
}