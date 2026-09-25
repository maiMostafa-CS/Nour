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

// ✅ event الرجوع من الأذكار → الفصول
class BackToChapters extends AzkarEvent {
  const BackToChapters();
}

// ✅ event الرجوع من الفصول → الأقسام
class BackToCategories extends AzkarEvent {
  const BackToCategories();
}