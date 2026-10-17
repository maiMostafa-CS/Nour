abstract class AzkarRepository {
  List<dynamic> getCategories([String langCode = 'ar']);

  List<dynamic> getChaptersByCategory(int categoryId, [String langCode = 'ar']);

  List<dynamic> getItemsByChapter(int chapterId, [String langCode = 'ar']);
}
