abstract class AzkarState {
  const AzkarState();
}

class AzkarInitial extends AzkarState {
  const AzkarInitial();
}

class AzkarLoading extends AzkarState {
  const AzkarLoading();
}

class AzkarCategoriesLoaded extends AzkarState {
  final List<dynamic> categories;

  const AzkarCategoriesLoaded(this.categories);
}

class AzkarChaptersLoaded extends AzkarState {
  final List<dynamic> chapters;
  final int categoryId;        // ✅ جديد — عشان نعرف رجعنا من أنهي category

  const AzkarChaptersLoaded(this.chapters, this.categoryId);
}

class AzkarItemsLoaded extends AzkarState {
  final List<dynamic> items;
  final int chapterId;         // ✅ جديد
  final int categoryId;        // ✅ جديد

  const AzkarItemsLoaded(
      this.items, {
        required this.chapterId,
        required this.categoryId,
      });
}

class AzkarError extends AzkarState {
  final String message;

  const AzkarError(this.message);
}