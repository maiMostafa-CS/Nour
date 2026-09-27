import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/khatma_progress_model.dart';
import '../model/khatma_weekly_report_model.dart';

abstract class KhatmaLocalDataSource {
  Future<KhatmaProgressModel> getProgress();

  Future<KhatmaProgressModel> markCurrentAyahAsRead();

  Future<Map<String, int>> getWeeklySnapshots();

  Future<KhatmaWeeklyReportModel> getWeeklyReport();

  Future<void> reset();
}

class KhatmaLocalDataSourceImpl implements KhatmaLocalDataSource {
  final SharedPreferences prefs;

  KhatmaLocalDataSourceImpl(this.prefs);

  static const String _currentAyahKey =
      'khatma_current_ayah';

  static const String _readAyahsKey =
      'khatma_read_ayahs';

  static const String _weeklySnapshotsKey =
      'khatma_weekly_snapshots';

  static const String _startedAtKey =
      'khatma_started_at';

  static const int totalAyahs = 6236;

  // ==========================================================
  // Progress
  // ==========================================================

  @override
  Future<KhatmaProgressModel> getProgress() async {
    final currentAyah =
        prefs.getInt(_currentAyahKey) ?? 1;

    final readAyahs =
        prefs.getInt(_readAyahsKey) ?? 0;

    return KhatmaProgressModel.fromPrefs(
      currentAyah: currentAyah,
      readAyahs: readAyahs,
    );
  }

  // ==========================================================
  // Mark current ayah as read
  // ==========================================================

  @override
  Future<KhatmaProgressModel> markCurrentAyahAsRead() async {
    final progress = await getProgress();

    // Khatma completed
    if (progress.currentAyah > totalAyahs) {
      return progress;
    }

    // ========================================================
    // Khatma start
    // ========================================================

    if (!prefs.containsKey(_startedAtKey)) {
      await prefs.setString(
        _startedAtKey,
        DateTime.now().toIso8601String(),
      );
    }

    // ========================================================
    // Update progress
    // ========================================================

    final newCurrentAyah =
        progress.currentAyah + 1;

    final newReadAyahs =
        progress.readAyahs + 1;

    await prefs.setInt(
      _currentAyahKey,
      newCurrentAyah,
    );

    await prefs.setInt(
      _readAyahsKey,
      newReadAyahs,
    );

    // ========================================================
    // Save total reading for the current week
    // ========================================================

    await _saveCurrentWeekSnapshot(
      newReadAyahs,
    );
    final weeklyReport =
    await getWeeklyReport();

    print(
      '📊 KHATMA WEEKLY: '
          'total=${weeklyReport.totalAyahs}, '
          'currentWeek=${weeklyReport.currentWeekAyahs}, '
          'week=${weeklyReport.weekNumber}',
    );
    return progress.copyWith(
      currentAyah: newCurrentAyah,
      readAyahs: newReadAyahs,
    );
  }

  // ==========================================================
  // Weekly snapshots
  // ==========================================================

  @override
  Future<Map<String, int>> getWeeklySnapshots() async {
    final jsonString =
    prefs.getString(_weeklySnapshotsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! Map) {
        return {};
      }

      return decoded.map<String, int>(
            (key, value) {
          return MapEntry(
            key.toString(),
            value is int
                ? value
                : int.tryParse(value.toString()) ?? 0,
          );
        },
      );
    } catch (_) {
      return {};
    }
  }

  // ==========================================================
  // Save current week snapshot
  // ==========================================================

  Future<void> _saveCurrentWeekSnapshot(
      int totalRead,
      ) async {
    final snapshots =
    await getWeeklySnapshots();

    final weekKey =
    _getWeekKey(DateTime.now());

    snapshots[weekKey] = totalRead;

    await prefs.setString(
      _weeklySnapshotsKey,
      jsonEncode(snapshots),
    );
  }

  // ==========================================================
  // Week key
  // ==========================================================

  String _getWeekKey(DateTime date) {
    final dateOnly = DateTime(
      date.year,
      date.month,
      date.day,
    );

    // Monday = start of week
    final daysFromMonday =
        dateOnly.weekday - DateTime.monday;

    final startOfWeek =
    dateOnly.subtract(
      Duration(days: daysFromMonday),
    );

    final month =
    startOfWeek.month
        .toString()
        .padLeft(2, '0');

    final day =
    startOfWeek.day
        .toString()
        .padLeft(2, '0');

    return '${startOfWeek.year}-$month-$day';
  }

  // ==========================================================
  // Get week number
  // ==========================================================

  int _getKhatmaWeekNumber() {
    final startedAtString =
    prefs.getString(_startedAtKey);

    if (startedAtString == null) {
      return 0;
    }

    final startedAt =
    DateTime.tryParse(startedAtString);

    if (startedAt == null) {
      return 0;
    }

    final now = DateTime.now();

    final difference =
        now.difference(startedAt).inDays;

    return (difference ~/ 7) + 1;
  }

  // ==========================================================
  // Weekly report
  // ==========================================================

  @override
  Future<KhatmaWeeklyReportModel> getWeeklyReport() async {
    final progress =
    await getProgress();

    // Khatma has not started yet
    if (progress.readAyahs == 0) {
      return const KhatmaWeeklyReportModel(
        totalAyahs: 0,
        currentWeekAyahs: 0,
        weekNumber: 0,
      );
    }

    final snapshots =
    await getWeeklySnapshots();

    final currentWeekKey =
    _getWeekKey(DateTime.now());

    final currentWeekTotal =
        snapshots[currentWeekKey] ??
            progress.readAyahs;

    // ========================================================
    // Calculate this week's reading only
    // ========================================================

    int previousWeekTotal = 0;

    final sortedKeys =
    snapshots.keys.toList()..sort();

    final currentWeekIndex =
    sortedKeys.indexOf(currentWeekKey);

    if (currentWeekIndex > 0) {
      previousWeekTotal =
      snapshots[
      sortedKeys[currentWeekIndex - 1]
    ] ??
    0;
    }

    final currentWeekAyahs =
    currentWeekTotal - previousWeekTotal;

    // ========================================================
    // Week number since Khatma started
    // ========================================================

    final weekNumber =
    _getKhatmaWeekNumber();

    return KhatmaWeeklyReportModel(
    // Total ayahs since Khatma started
    totalAyahs: progress.readAyahs,

    // Number of new ayahs in the current week
    currentWeekAyahs:
    currentWeekAyahs < 0
    ? 0
        : currentWeekAyahs,

    // Week number
    weekNumber: weekNumber,
    );
  }

  // ==========================================================
  // Reset
  // ==========================================================

  @override
  Future<void> reset() async {
    await prefs.remove(
      _currentAyahKey,
    );

    await prefs.remove(
      _readAyahsKey,
    );

    await prefs.remove(
      _weeklySnapshotsKey,
    );

    await prefs.remove(
      _startedAtKey,
    );
  }
}