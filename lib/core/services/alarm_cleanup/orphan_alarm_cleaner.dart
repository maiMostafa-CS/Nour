import 'package:alarm/alarm.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'alarm_id_tracker.dart';

/// ينظّف المنبهات اليتيمة من الجلسات السابقة
class OrphanAlarmCleaner {
  static const _sweptKey = 'has_swept_orphan_alarms';

  final AlarmIdTracker _tracker;
  final SharedPreferences _prefs;

  OrphanAlarmCleaner(this._tracker, this._prefs);

  /// نظّف المنبهات اليتيمة
  Future<void> cleanOrphans() async {
    debugPrint('🧹 [Cleaner] START');

    final savedIds = _tracker.getAll();
    debugPrint('🧹 [Cleaner] tracked IDs: ${savedIds.length}');

    // 1️⃣ الغِ الـ IDs المحفوظة
    if (savedIds.isNotEmpty) {
      await _cancelIds(savedIds);
      await _tracker.clear();
      debugPrint('🧹 [Cleaner] cleared ${savedIds.length} IDs');
    }

    // 2️⃣ دايماً اعمل sweep دفاعي
    await _sweepKnownRanges();

    debugPrint('🧹 [Cleaner] DONE');
  }

  /// الغِ مجموعة معرّفات (بالاتنين: alarm + android_alarm_manager)
  Future<void> _cancelIds(List<int> ids) async {
    await Future.wait(
      ids.map((id) async {
        // 1️⃣ إلغاء من android_alarm_manager_plus
        try {
          await AndroidAlarmManager.cancel(id);
        } catch (e) {
          // متوقع
        }

        // 2️⃣ إلغاء من إضافة alarm (اللي بتسبب المشكلة)
        try {
          await Alarm.stop(id);
        } catch (e) {
          // متوقع
        }
      }),
    );
  }

  /// مسح دفاعي للنطاقات المعروفة
  Future<void> _sweepKnownRanges() async {
    // ⚠️ عدّل الأرقام دي حسب مشروعك
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

  /// إعادة تعيين الـ swept flag (للاستخدام اليدوي/الاختبار)
  Future<void> resetSweptFlag() async {
    await _prefs.remove(_sweptKey);
  }
}