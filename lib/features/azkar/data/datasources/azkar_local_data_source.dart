import 'package:azkar/azkar.dart';

class AzkarLocalDataSource {
  AzkarLang _toLang(String langCode) {
    return langCode.toLowerCase() == 'en'
        ? AzkarLang.english
        : AzkarLang.arabic;
  }

  List<dynamic> getCategories([String langCode = 'ar']) {
    return Azkar.getCategories(_toLang(langCode));
  }

  List<dynamic> getChaptersByCategory(int categoryId, [String langCode = 'ar']) {
    return Azkar.getChaptersByCategory(
      _toLang(langCode),
      categoryId,
    );
  }

  List<dynamic> getItemsByChapter(int chapterId, [String langCode = 'ar']) {
    final items = Azkar.getItemsByChapter(
      _toLang(langCode),
      chapterId,
    );

    for (final item in items) {
      print('TYPE: ${item.runtimeType}');
      print('ITEM: $item');
    }

    return items;
  }
}
