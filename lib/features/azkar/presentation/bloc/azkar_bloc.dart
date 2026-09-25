import 'package:flutter/cupertino.dart';
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

  int? _currentCategoryId;
  int? _currentChapterId;

  AzkarBloc({
    required this.getAzkarCategories,
    required this.getAzkarChapters,
    required this.getAzkarItems,
  }) : super(const AzkarInitial()) {
    on<LoadAzkarCategories>(_onLoadCategories);
    on<LoadAzkarChapters>(_onLoadChapters);
    on<LoadAzkarItems>(_onLoadItems);
    on<BackToChapters>(_onBackToChapters);
    on<BackToCategories>(_onBackToCategories);
  }

  void _onLoadCategories(
      LoadAzkarCategories event,
      Emitter<AzkarState> emit,
      ) {
    try {
      emit(const AzkarLoading());

      _currentCategoryId = null;
      _currentChapterId = null;

      final allCategories = getAzkarCategories();

      final categoriesWithAzkar = allCategories.where((category) {
        final chapters = getAzkarChapters(category.id);

        return chapters.any((chapter) {
          final items = getAzkarItems(chapter.id);
          return items.isNotEmpty;
        });
      }).toList();

      debugPrint(
        '📚 CATEGORIES: '
            '${allCategories.length} → '
            '${categoriesWithAzkar.length} with azkar',
      );

      emit(
        AzkarCategoriesLoaded(categoriesWithAzkar),
      );
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

      _currentCategoryId = event.categoryId;
      _currentChapterId = null;

      final allChapters = getAzkarChapters(event.categoryId);

      final chaptersWithAzkar = allChapters.where((chapter) {
        final items = getAzkarItems(chapter.id);
        return items.isNotEmpty;
      }).toList();

      debugPrint(
        '📚 CATEGORY ${event.categoryId}: '
            '${allChapters.length} chapters → '
            '${chaptersWithAzkar.length} with azkar',
      );

      emit(
        AzkarChaptersLoaded(
          chaptersWithAzkar,
          event.categoryId,
        ),
      );
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

      _currentChapterId = event.chapterId;

      final items = getAzkarItems(event.chapterId);

      debugPrint(
        '📿 CHAPTER ${event.chapterId} → ITEMS: ${items.length}',
      );

      for (final item in items) {
        debugPrint(
          '   └─ itemId=${item.id} | count=${item.count} | text=${item.text}',
        );
      }

      emit(
        AzkarItemsLoaded(
          items,
          chapterId: event.chapterId,
          categoryId: _currentCategoryId!,
        ),
      );
    } catch (e) {
      emit(AzkarError(e.toString()));
    }
  }

  void _onBackToChapters(
      BackToChapters event,
      Emitter<AzkarState> emit,
      ) {
    if (_currentCategoryId == null) {
      _onBackToCategories(
        const BackToCategories(),
        emit,
      );
      return;
    }

    try {
      emit(const AzkarLoading());

      _currentChapterId = null;

      final allChapters =
      getAzkarChapters(_currentCategoryId!);

      final chaptersWithAzkar = allChapters.where((chapter) {
        final items = getAzkarItems(chapter.id);
        return items.isNotEmpty;
      }).toList();

      emit(
        AzkarChaptersLoaded(
          chaptersWithAzkar,
          _currentCategoryId!,
        ),
      );
    } catch (e) {
      emit(AzkarError(e.toString()));
    }
  }

  void _onBackToCategories(
      BackToCategories event,
      Emitter<AzkarState> emit,
      ) {
    try {
      emit(const AzkarLoading());
      _currentCategoryId = null;
      _currentChapterId = null;
      emit(AzkarCategoriesLoaded(getAzkarCategories()));
    } catch (e) {
      emit(AzkarError(e.toString()));
    }
  }
}