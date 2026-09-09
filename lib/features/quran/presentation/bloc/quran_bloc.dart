import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/surah_entity.dart';
import '../../domain/usecases/get_surahs.dart';

part 'quran_event.dart';
part 'quran_state.dart';

class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final GetSurahs getSurahs;

  QuranBloc(this.getSurahs) : super(const QuranInitial()) {
    on<LoadQuran>((event, emit) async {
      emit(const QuranLoading());
      try {
        emit(QuranLoaded(await getSurahs()));
      } catch (e) {
        emit(QuranError(e.toString()));
      }
    });
  }
}
