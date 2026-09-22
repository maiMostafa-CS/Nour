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

  const AzkarChaptersLoaded(this.chapters);
}

class AzkarItemsLoaded extends AzkarState {
  final List<dynamic> items;

  const AzkarItemsLoaded(this.items);
}

class AzkarError extends AzkarState {
  final String message;

  const AzkarError(this.message);
}
