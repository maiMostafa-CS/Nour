import 'package:azkar/azkar.dart';

class AzkarLocalDataSource {
  List<dynamic> getCategories() {
    return Azkar.getCategories(AzkarLang.arabic);
  }

  List<dynamic> getChaptersByCategory(int categoryId) {
    return Azkar.getChaptersByCategory(
      AzkarLang.arabic,
      categoryId,
    );
  }
  List<dynamic> getItemsByChapter(int chapterId) {
    final items = Azkar.getItemsByChapter(
      AzkarLang.arabic,
      chapterId,
    );

    for (final item in items) {
      print('TYPE: ${item.runtimeType}');
      print('ITEM: $item');
    }

    return items;
  }
}
