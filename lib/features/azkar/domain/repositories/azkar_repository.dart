abstract class AzkarRepository {
  List<dynamic> getCategories();

  List<dynamic> getChaptersByCategory(int categoryId);

  List<dynamic> getItemsByChapter(int chapterId);
}
