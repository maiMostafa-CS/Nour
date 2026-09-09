part of 'quran_bloc.dart';

sealed class QuranState extends Equatable {
  const QuranState();
}

class QuranInitial extends QuranState {
  const QuranInitial();
  @override List<Object?> get props => [];
}

class QuranLoading extends QuranState {
  const QuranLoading();
  @override List<Object?> get props => [];
}

class QuranLoaded extends QuranState {
  final List<SurahEntity> surahs;
  const QuranLoaded(this.surahs);
  @override List<Object?> get props => [surahs];
}

class QuranError extends QuranState {
  final String message;
  const QuranError(this.message);
  @override List<Object?> get props => [message];
}
