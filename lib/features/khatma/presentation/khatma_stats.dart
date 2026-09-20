import 'package:shared_preferences/shared_preferences.dart';

class KhatmaStats {
  static const totalAyahs = 6236;

  static Future<Map<String, int>> read() async {
    final prefs = await SharedPreferences.getInstance();
    final read = prefs.getInt('khatma_read_ayahs') ?? 0;
    final current = prefs.getInt('khatma_current_ayah') ?? 1;

    return {
      'read': read,
      'remaining': (totalAyahs - read).clamp(0, totalAyahs),
      'current': current.clamp(1, totalAyahs + 1),
    };
  }
}
