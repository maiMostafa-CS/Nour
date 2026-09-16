import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/surah_entity.dart';
import '../../domain/usecases/get_page.dart';
import '../../domain/usecases/get_surahs.dart';

part 'quran_event.dart';
part 'quran_state.dart';

class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final GetSurahs getSurahs;
  final GetPage getPage;

  QuranBloc({
    required this.getSurahs,
    required this.getPage,
  }) : super(const QuranInitial()) {
    on<LoadSurahs>(_onLoadSurahs);
    on<LoadPage>(_onLoadPage);
  }

  Future<void> _onLoadSurahs(
      LoadSurahs event,
      Emitter<QuranState> emit,
      ) async {
    emit(const QuranLoading());

    try {
      final surahs = await getSurahs();

      emit(
        QuranLoaded(surahs),
      );
    } catch (e) {
      emit(
        QuranError(e.toString()),
      );
    }
  }

  Future<void> _onLoadPage(
      LoadPage event,
      Emitter<QuranState> emit,
      ) async {
    emit(
      QuranPageLoading(
        pageNumber: event.pageNumber,
      ),
    );

    try {
      final page = await getPage(
        event.pageNumber,
      );

      emit(
        QuranPageLoaded(page),
      );
    } catch (e) {
      emit(
        QuranError(e.toString()),
      );
    }
  }
}