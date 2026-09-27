import 'package:shared_preferences/shared_preferences.dart';

class QuranBookmarkService {
  static const String _savedPageKey = 'saved_quran_page';

  /// Save page
  static Future<bool> savePage(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.setInt(
      _savedPageKey,
      pageNumber,
    );
  }

  /// Get saved page
  static Future<int?> getSavedPage() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_savedPageKey);
  }

  /// Delete saved page
  static Future<bool> removeSavedPage() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.remove(_savedPageKey);
  }

  /// Is a saved page available?
  static Future<bool> hasSavedPage() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(_savedPageKey);
  }
}