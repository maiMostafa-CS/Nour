import 'package:equatable/equatable.dart';

import '../../domain/entities/surah_entity.dart';


abstract class QuranIndexState extends Equatable {
  const QuranIndexState();

  @override
  List<Object?> get props => [];
}

class QuranIndexInitial extends QuranIndexState {}

class QuranIndexLoading extends QuranIndexState {}

class QuranIndexLoaded extends QuranIndexState {
  final List<Surah> allSurahs;
  final List<Surah> filteredSurahs;

  const QuranIndexLoaded({
    required this.allSurahs,
    required this.filteredSurahs,
  });

  @override
  List<Object?> get props => [
    allSurahs,
    filteredSurahs,
  ];
}

class QuranIndexError extends QuranIndexState {
  final String message;

  const QuranIndexError(this.message);

  @override
  List<Object?> get props => [message];
}