part of 'quran_bloc.dart';

sealed class QuranEvent extends Equatable {
  const QuranEvent();

  @override
  List<Object?> get props => [];
}

class LoadSurahs extends QuranEvent {
  const LoadSurahs();
}

class LoadPage extends QuranEvent {
  final int pageNumber;

  const LoadPage(this.pageNumber);

  @override
  List<Object?> get props => [
    pageNumber,
  ];
}