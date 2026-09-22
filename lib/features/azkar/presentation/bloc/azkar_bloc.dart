import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_azkar_categories.dart';
import '../../domain/usecases/get_azkar_chapters.dart';
import '../../domain/usecases/get_azkar_items.dart';
import 'azkar_event.dart';
import 'azkar_state.dart';

class AzkarBloc extends Bloc<AzkarEvent, AzkarState> {
  final GetAzkarCategories getAzkarCategories;
  final GetAzkarChapters getAzkarChapters;
  final GetAzkarItems getAzkarItems;

  AzkarBloc({
    required this.getAzkarCategories,
    required this.getAzkarChapters,
    required this.getAzkarItems,
  }) : super(const AzkarInitial()) {
    on<LoadAzkarCategories>(_onLoadCategories);
    on<LoadAzkarChapters>(_onLoadChapters);
    on<LoadAzkarItems>(_onLoadItems);
  }

  void _onLoadCategories(
    LoadAzkarCategories event,
    Emitter<AzkarState> emit,
  ) {
    try {
      emit(const AzkarLoading());
      emit(AzkarCategoriesLoaded(getAzkarCategories()));
    } catch (e) {
      emit(AzkarError(e.toString()));
    }
  }

  void _onLoadChapters(
    LoadAzkarChapters event,
    Emitter<AzkarState> emit,
  ) {
    try {
      emit(const AzkarLoading());
      emit(AzkarChaptersLoaded(getAzkarChapters(event.categoryId)));
    } catch (e) {
      emit(AzkarError(e.toString()));
    }
  }

  void _onLoadItems(
    LoadAzkarItems event,
    Emitter<AzkarState> emit,
  ) {
    try {
      emit(const AzkarLoading());
      emit(AzkarItemsLoaded(getAzkarItems(event.chapterId)));
    } catch (e) {
      emit(AzkarError(e.toString()));
    }
  }
}
