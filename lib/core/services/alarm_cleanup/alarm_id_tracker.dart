import 'package:shared_preferences/shared_preferences.dart';

/// Tracks the alarm IDs scheduled by the app
/// So they can be cancelled in the next session
class AlarmIdTracker {
  static const _key = 'scheduled_alarm_ids';

  final SharedPreferences _prefs;

  AlarmIdTracker(this._prefs);

  /// Record a new alarm ID
  Future<void> track(int id) async {
    final ids = _prefs.getStringList(_key) ?? [];
    final idStr = id.toString();
    if (!ids.contains(idStr)) {
      ids.add(idStr);
      await _prefs.setStringList(_key, ids);
    }
  }

  /// Record a group of IDs at once
  Future<void> trackAll(List<int> ids) async {
    if (ids.isEmpty) return;
    final existing = _prefs.getStringList(_key) ?? [];
    final existingSet = existing.toSet();
    for (final id in ids) {
      existingSet.add(id.toString());
    }
    await _prefs.setStringList(_key, existingSet.toList());
  }

  /// Return all saved IDs
  List<int> getAll() {
    final ids = _prefs.getStringList(_key) ?? [];
    return ids.map(int.tryParse).whereType<int>().toList();
  }

  /// Number of saved IDs
  int get count => (_prefs.getStringList(_key) ?? []).length;

  /// Clear all IDs
  Future<void> clear() async {
    await _prefs.remove(_key);
  }

  /// Clear one ID
  Future<void> untrack(int id) async {
    final ids = _prefs.getStringList(_key) ?? [];
    ids.remove(id.toString());
    await _prefs.setStringList(_key, ids);
  }

  /// Clear a group of IDs
  Future<void> untrackAll(List<int> ids) async {
    final existing = _prefs.getStringList(_key) ?? [];
    final toRemove = ids.map((e) => e.toString()).toSet();
    existing.removeWhere(toRemove.contains);
    await _prefs.setStringList(_key, existing);
  }
}