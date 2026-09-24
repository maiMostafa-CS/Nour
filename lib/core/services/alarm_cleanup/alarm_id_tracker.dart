import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// يتتبع معرّفات المنبهات اللي التطبيق جدولها
/// عشان نقدر نلغيها في الجلسة الجاية
class AlarmIdTracker {
  static const _key = 'scheduled_alarm_ids';

  final SharedPreferences _prefs;

  AlarmIdTracker(this._prefs);

  /// سجّل معرّف منبه جديد
  Future<void> track(int id) async {
    final ids = _prefs.getStringList(_key) ?? [];
    final idStr = id.toString();
    if (!ids.contains(idStr)) {
      ids.add(idStr);
      await _prefs.setStringList(_key, ids);
    }
  }

  /// سجّل مجموعة معرّفات مرة واحدة
  Future<void> trackAll(List<int> ids) async {
    if (ids.isEmpty) return;
    final existing = _prefs.getStringList(_key) ?? [];
    final existingSet = existing.toSet();
    for (final id in ids) {
      existingSet.add(id.toString());
    }
    await _prefs.setStringList(_key, existingSet.toList());
  }

  /// ارجع كل المعرّفات المحفوظة
  List<int> getAll() {
    final ids = _prefs.getStringList(_key) ?? [];
    return ids.map(int.tryParse).whereType<int>().toList();
  }

  /// عدد المعرّفات المحفوظة
  int get count => (_prefs.getStringList(_key) ?? []).length;

  /// امسح كل المعرّفات
  Future<void> clear() async {
    await _prefs.remove(_key);
  }

  /// امسح معرّف واحد
  Future<void> untrack(int id) async {
    final ids = _prefs.getStringList(_key) ?? [];
    ids.remove(id.toString());
    await _prefs.setStringList(_key, ids);
  }

  /// امسح مجموعة معرّفات
  Future<void> untrackAll(List<int> ids) async {
    final existing = _prefs.getStringList(_key) ?? [];
    final toRemove = ids.map((e) => e.toString()).toSet();
    existing.removeWhere(toRemove.contains);
    await _prefs.setStringList(_key, existing);
  }
}