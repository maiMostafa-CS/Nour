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
