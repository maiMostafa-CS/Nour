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

  /// Clean orphan alarms — ONE-TIME migration only.
  ///
  /// ⚠️ This must NOT run on every launch: the tracked IDs and the swept
  /// ranges contain the *currently valid* Adhan/Iqama alarms, so running it
  /// each startup silently cancelled every scheduled prayer alarm.
  Future<void> cleanOrphans() async {
    if (_prefs.getBool(_sweptKey) ?? false) {
      debugPrint('🧹 [Cleaner] already swept once → SKIP');
      return;
    }

    debugPrint('🧹 [Cleaner] START');

    final savedIds = _tracker.getAll();
    debugPrint('🧹 [Cleaner] tracked IDs: ${savedIds.length}');

    // 1️⃣ Cancel the saved IDs
    if (savedIds.isNotEmpty) {
      await _cancelIds(savedIds);
      await _tracker.clear();
      debugPrint('🧹 [Cleaner] cleared ${savedIds.length} IDs');
    }

    // 2️⃣ Defensive sweep (one time)
    await _sweepKnownRanges();

    await _prefs.setBool(_sweptKey, true);

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

  /// Defensive cleanup of known ranges - disabled to prevent wiping active prayer alarms
  Future<void> _sweepKnownRanges() async {
    // Intentionally no-op: arbitrary ID ranges overlap with active scheduled prayers.
    debugPrint('🧹 [Cleaner] sweeping arbitrary ranges is disabled to protect scheduled alarms');
  }

  /// Reset the swept flag (for manual use/testing)
  Future<void> resetSweptFlag() async {
    await _prefs.remove(_sweptKey);
  }
}