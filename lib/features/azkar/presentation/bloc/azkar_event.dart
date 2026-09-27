abstract class AzkarEvent {
  const AzkarEvent();
}

class LoadAzkarCategories extends AzkarEvent {
  const LoadAzkarCategories();
}

class LoadAzkarChapters extends AzkarEvent {
  final int categoryId;

  const LoadAzkarChapters(this.categoryId);
}

class LoadAzkarItems extends AzkarEvent {
  final int chapterId;

  const LoadAzkarItems(this.chapterId);
}

// ✅ Back event from adhkar → chapters
class BackToChapters extends AzkarEvent {
  const BackToChapters();
}

// ✅ Back event from chapters → categories
class BackToCategories extends AzkarEvent {
  const BackToCategories();
}