abstract class QuranIndexEvent {}

class LoadSurahs extends QuranIndexEvent {}

class SearchSurahsEvent extends QuranIndexEvent {
  final String query;

  SearchSurahsEvent(this.query);
}

class ClearSurahSearch extends QuranIndexEvent {}