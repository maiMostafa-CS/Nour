import 'package:equatable/equatable.dart';

abstract class QuranIndexEvent extends Equatable {
  const QuranIndexEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// SURAH
// ============================================================

class LoadSurahs extends QuranIndexEvent {
  const LoadSurahs();
}

class SearchSurahsEvent extends QuranIndexEvent {
  final String query;

  const SearchSurahsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSurahSearch extends QuranIndexEvent {
  const ClearSurahSearch();
}

// ============================================================
// AUDIO
// ============================================================

class LoadReciters extends QuranIndexEvent {
  const LoadReciters();
}

class SelectReciter extends QuranIndexEvent {
  final String identifier;

  const SelectReciter(this.identifier);

  @override
  List<Object?> get props => [identifier];
}

class PlayAyah extends QuranIndexEvent {
  final String reciterIdentifier;
  final int globalAyahNumber;

  const PlayAyah({
    required this.reciterIdentifier,
    required this.globalAyahNumber,
  });

  @override
  List<Object?> get props => [
        reciterIdentifier,
        globalAyahNumber,
      ];
}

class PauseAyah extends QuranIndexEvent {
  const PauseAyah();
}

class ResumeAyah extends QuranIndexEvent {
  const ResumeAyah();
}

class StopAyah extends QuranIndexEvent {
  const StopAyah();
}
// ============================================================
// TAFSIR
// ============================================================

class LoadTafsirBooks extends QuranIndexEvent {
  final int surahNumber;

  const LoadTafsirBooks(this.surahNumber);

  @override
  List<Object?> get props => [surahNumber];
}

class SelectTafsirBook extends QuranIndexEvent {
  final int bookId;

  const SelectTafsirBook(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class LoadAyahTafsir extends QuranIndexEvent {
  final int surahNumber;
  final int ayahNumber;

  const LoadAyahTafsir({
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  List<Object?> get props => [
    surahNumber,
    ayahNumber,
  ];
}

class ClearAyahTafsir extends QuranIndexEvent {
  const ClearAyahTafsir();
}