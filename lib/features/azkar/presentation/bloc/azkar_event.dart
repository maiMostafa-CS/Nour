abstract class AzkarEvent {
  const AzkarEvent();
}

class LoadAzkarCategories extends AzkarEvent {
  final String? langCode;

  const LoadAzkarCategories({this.langCode});
}

class LoadAzkarChapters extends AzkarEvent {
  final int categoryId;
  final String? langCode;

  const LoadAzkarChapters(this.categoryId, {this.langCode});
}

class LoadAzkarItems extends AzkarEvent {
  final int chapterId;
  final String? langCode;

  const LoadAzkarItems(this.chapterId, {this.langCode});
}

// ✅ Back event from adhkar → chapters
class BackToChapters extends AzkarEvent {
  const BackToChapters();
}

// ✅ Back event from chapters → categories
class BackToCategories extends AzkarEvent {
  const BackToCategories();
}