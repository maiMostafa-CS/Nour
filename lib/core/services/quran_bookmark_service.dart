import 'package:shared_preferences/shared_preferences.dart';

class QuranBookmarkService {
  static const String _savedPageKey = 'saved_quran_page';

  /// حفظ الصفحة
  static Future<bool> savePage(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.setInt(
      _savedPageKey,
      pageNumber,
    );
  }

  /// جلب الصفحة المحفوظة
  static Future<int?> getSavedPage() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_savedPageKey);
  }

  /// حذف الصفحة المحفوظة
  static Future<bool> removeSavedPage() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.remove(_savedPageKey);
  }

  /// هل توجد صفحة محفوظة؟
  static Future<bool> hasSavedPage() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(_savedPageKey);
  }
}