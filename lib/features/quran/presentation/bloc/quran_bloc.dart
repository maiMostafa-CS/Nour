import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/features/quran/presentation/bloc/quran_event.dart';
import 'package:islamic_app/features/quran/presentation/bloc/quran_state.dart';
import '../../domain/entities/surah_entity.dart';
import '../../domain/usecases/get_surahs.dart';
import '../../domain/usecases/search_surahs.dart';


class QuranIndexBloc
    extends Bloc<QuranIndexEvent, QuranIndexState> {
  final GetSurahs getSurahs;
  final SearchSurahs searchSurahs;

  List<Surah> _allSurahs = [];

  QuranIndexBloc({
    required this.getSurahs,
    required this.searchSurahs,
  }) : super(QuranIndexInitial()) {
    on<LoadSurahs>(_onLoadSurahs);
    on<SearchSurahsEvent>(_onSearchSurahs);
    on<ClearSurahSearch>(_onClearSearch);
  }

  Future<void> _onLoadSurahs(
      LoadSurahs event,
      Emitter<QuranIndexState> emit,
      ) async {
    if (_allSurahs.isNotEmpty) {
      emit(
        QuranIndexLoaded(
          allSurahs: _allSurahs,
          filteredSurahs: _allSurahs,
        ),
      );

      return;
    }

    emit(QuranIndexLoading());

    try {
      final result = await getSurahs();

      _allSurahs = result;

      emit(
        QuranIndexLoaded(
          allSurahs: result,
          filteredSurahs: result,
        ),
      );
    } catch (e) {
      emit(
        const QuranIndexError(
          'حدث خطأ أثناء تحميل فهرس القرآن',
        ),
      );
    }
  }

  void _onSearchSurahs(
      SearchSurahsEvent event,
      Emitter<QuranIndexState> emit,
      ) {
    if (state is! QuranIndexLoaded) {
      return;
    }

    final result = searchSurahs(
      _allSurahs,
      event.query,
    );

    emit(
      QuranIndexLoaded(
        allSurahs: _allSurahs,
        filteredSurahs: result,
      ),
    );
  }

  void _onClearSearch(
      ClearSurahSearch event,
      Emitter<QuranIndexState> emit,
      ) {
    emit(
      QuranIndexLoaded(
        allSurahs: _allSurahs,
        filteredSurahs: _allSurahs,
      ),
    );
  }
}