import 'package:shared_preferences/shared_preferences.dart';

class QuranFontSizeService {
  QuranFontSizeService._();

  static const String _key = 'quran_font_size_scale';
  static const double defaultScale = 0.855;

  static const List<double> availableScales = [
    0.75,
    0.855,
    0.95,
    1.05,
    1.20,
    1.35,
  ];

  static Future<double> getFontSizeScale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scale = prefs.getDouble(_key) ?? defaultScale;
      return closestScale(scale);
    } catch (_) {
      return defaultScale;
    }
  }

  static Future<bool> saveFontSizeScale(double scale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setDouble(_key, scale);
    } catch (_) {
      return false;
    }
  }

  static double closestScale(double scale) {
    if (availableScales.contains(scale)) return scale;
    double closest = availableScales.first;
    double minDiff = (scale - closest).abs();
    for (final v in availableScales) {
      final diff = (scale - v).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = v;
      }
    }
    return closest;
  }
}
