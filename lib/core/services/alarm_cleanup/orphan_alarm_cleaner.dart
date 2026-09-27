import 'package:alarm/alarm.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'alarm_id_tracker.dart';

/// Cleans orphan alarms from previous sessions
class OrphanAlarmCleaner {
  static const _sweptKey = 'has_swept_orphan_alarms';

  final AlarmIdTracker _tracker;
  final SharedPreferences _prefs;

  OrphanAlarmCleaner(this._tracker, this._prefs);

  /// Clean orphan alarms
  Future<void> cleanOrphans() async {
    debugPrint('🧹 [Cleaner] START');

    final savedIds = _tracker.getAll();
    debugPrint('🧹 [Cleaner] tracked IDs: ${savedIds.length}');

    // 1️⃣ Cancel the saved IDs
    if (savedIds.isNotEmpty) {
      await _cancelIds(savedIds);
      await _tracker.clear();
      debugPrint('🧹 [Cleaner] cleared ${savedIds.length} IDs');
    }

    // 2️⃣ Always perform a defensive sweep
    await _sweepKnownRanges();

    debugPrint('🧹 [Cleaner] DONE');
  }

  /// Cancel a group of IDs (from both alarm + android_alarm_manager)
  Future<void> _cancelIds(List<int> ids) async {
    await Future.wait(
      ids.map((id) async {
        // 1️⃣ Cancel from android_alarm_manager_plus
        try {
          await AndroidAlarmManager.cancel(id);
        } catch (e) {
          // Expected
        }

        // 2️⃣ Cancel from the alarm plugin (the one causing the issue)
        try {
          await Alarm.stop(id);
        } catch (e) {
          // Expected
        }
      }),
    );
  }

  /// Defensive cleanup of known ranges
  Future<void> _sweepKnownRanges() async {
    // ⚠️ Adjust these numbers for your project
    const adhanBase = 124570;
    const iqamaBase = 324570;
    const countdownBase = 424570;
    const sweepRange = 200;

    final bases = [adhanBase, iqamaBase, countdownBase];

    debugPrint('🧹 [Cleaner] sweeping ranges: $bases × $sweepRange');

    final allIds = <int>[];
    for (final base in bases) {
      for (int i = 0; i < sweepRange; i++) {
        allIds.add(base + i);
      }
    }

    await _cancelIds(allIds);
    debugPrint('🧹 [Cleaner] swept ${allIds.length} IDs');
  }

  /// Reset the swept flag (for manual use/testing)
  Future<void> resetSweptFlag() async {
    await _prefs.remove(_sweptKey);
  }
}