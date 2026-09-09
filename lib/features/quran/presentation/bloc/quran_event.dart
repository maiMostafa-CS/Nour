part of 'quran_bloc.dart';

sealed class QuranEvent extends Equatable {
  const QuranEvent();
  @override List<Object?> get props => [];
}

class LoadQuran extends QuranEvent {
  const LoadQuran();
}
