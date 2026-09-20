import 'package:shared_preferences/shared_preferences.dart';

class KhatmaStats {
  static const int totalAyahs = 6236;

  static const String _readAyahsKey = 'khatma_read_ayahs';
  static const String _currentAyahKey = 'khatma_current_ayah';
  static const String _startedAtKey = 'khatma_started_at';

  static Future<Map<String, int>> read() async {
    final prefs = await SharedPreferences.getInstance();

    final read =
        prefs.getInt(_readAyahsKey) ?? 0;

    final current =
        prefs.getInt(_currentAyahKey) ?? 1;

    return {
      'read': read,
      'remaining':
      (totalAyahs - read).clamp(0, totalAyahs),
      'current':
      current.clamp(1, totalAyahs + 1),
    };
  }

  static Future<void> ensureStarted() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_startedAtKey)) {
      await prefs.setString(
        _startedAtKey,
        DateTime.now().toIso8601String(),
      );
    }
  }

  static Future<int> getWeekNumber() async {
    final prefs = await SharedPreferences.getInstance();

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

  static Future<Map<String, int>> readWeeklyStats() async {
    final stats = await read();

    final weekNumber =
    await getWeekNumber();

    return {
      'totalAyahs': stats['read'] ?? 0,
      'weekNumber': weekNumber,
      'currentAyah': stats['current'] ?? 1,
      'remaining': stats['remaining'] ?? totalAyahs,
    };
  }
}