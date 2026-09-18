import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:islamic_app/features/quran/presentation/bloc/quran_event.dart';
import 'package:islamic_app/features/quran/presentation/bloc/quran_state.dart';

import '../../../../core/services/ayah_audio_service.dart';

import '../../domain/entities/surah_entity.dart';

import '../../domain/usecases/ get_ayah_audio_url.dart';
import '../../domain/usecases/get_surahs.dart';
import '../../domain/usecases/search_surahs.dart';

import '../../domain/usecases/get_quran_reciters.dart';
import '../../domain/entities/quran_reciter.dart';

class QuranIndexBloc extends Bloc<QuranIndexEvent, QuranIndexState> {
// ==========================================================
// Quran Index
// ==========================================================

  final GetSurahs getSurahs;
  final SearchSurahs searchSurahs;

  List<Surah> _allSurahs = [];

// ==========================================================
// Audio UseCases
// ==========================================================

  final GetQuranReciters getQuranReciters;
  final GetAyahAudioUrl getAyahAudioUrl;

// ==========================================================
// Audio Service
// ==========================================================

  final AyahAudioService audioService;

  QuranIndexBloc({
    required this.getSurahs,
    required this.searchSurahs,
    required this.getQuranReciters,
    required this.getAyahAudioUrl,
    required this.audioService,
  }) : super(const QuranIndexInitial()) {
// ========================================================
// Surah
// ========================================================

    on<LoadSurahs>(_onLoadSurahs);
    on<SearchSurahsEvent>(_onSearchSurahs);
    on<ClearSurahSearch>(_onClearSearch);

// ========================================================
// Audio
// ========================================================

    on<LoadReciters>(_onLoadReciters);
    on<SelectReciter>(_onSelectReciter);

    on<PlayAyah>(_onPlayAyah);
    on<PauseAyah>(_onPauseAyah);
    on<ResumeAyah>(_onResumeAyah);
    on<StopAyah>(_onStopAyah);
  }

// ==========================================================
// LOAD SURAHS
// ==========================================================

  Future<void> _onLoadSurahs(
    LoadSurahs event,
    Emitter<QuranIndexState> emit,
  ) async {
    debugPrint('🟢 _onLoadSurahs called');
    debugPrint(
      '   _allSurahs.length = ${_allSurahs.length}',
    );

// --------------------------------------------------------
// Cache
// --------------------------------------------------------

    if (_allSurahs.isNotEmpty) {
      debugPrint('   ✅ using cached surahs');

      if (state is QuranIndexLoaded) {
        final currentState = state as QuranIndexLoaded;

        emit(
          currentState.copyWith(
            allSurahs: _allSurahs,
            filteredSurahs: _allSurahs,
          ),
        );
      } else {
        final reciters = getQuranReciters();

        emit(
          QuranIndexLoaded(
            allSurahs: _allSurahs,
            filteredSurahs: _allSurahs,
            reciters: reciters,
            selectedReciter: reciters.isNotEmpty ? reciters.first : null,
          ),
        );
      }

      return;
    }

// --------------------------------------------------------
// Loading
// --------------------------------------------------------

    emit(const QuranIndexLoading());

    debugPrint('   ⏳ loading...');

    try {
// ------------------------------------------------------
// Load Surahs
// ------------------------------------------------------

      final result = await getSurahs();

      debugPrint(
        '   📚 getSurahs returned '
        '${result.length} surahs',
      );

      _allSurahs = result;

// ------------------------------------------------------
// Load Reciters through UseCase
// ------------------------------------------------------

      final reciters = getQuranReciters();

      debugPrint(
        '   🎧 reciters = ${reciters.length}',
      );

      debugPrint(
        '   🎧 first = '
        '${reciters.isNotEmpty ? reciters.first.identifier : "NONE"}',
      );

// ------------------------------------------------------
// Loaded
// ------------------------------------------------------

      emit(
        QuranIndexLoaded(
          allSurahs: result,
          filteredSurahs: result,
          reciters: reciters,
          selectedReciter: reciters.isNotEmpty ? reciters.first : null,
        ),
      );

      debugPrint(
        '   ✅ QuranIndexLoaded emitted',
      );
    } catch (e, st) {
      debugPrint(
        '   ❌ Error: $e',
      );

      debugPrint('$st');

      emit(
        const QuranIndexError(
          'حدث خطأ أثناء تحميل فهرس القرآن',
        ),
      );
    }
  }

// ==========================================================
// SEARCH
// ==========================================================

  void _onSearchSurahs(
    SearchSurahsEvent event,
    Emitter<QuranIndexState> emit,
  ) {
    if (state is! QuranIndexLoaded) {
      return;
    }

    final currentState = state as QuranIndexLoaded;

    final result = searchSurahs(
      _allSurahs,
      event.query,
    );

    emit(
      currentState.copyWith(
        filteredSurahs: result,
      ),
    );
  }

// ==========================================================
// CLEAR SEARCH
// ==========================================================

  void _onClearSearch(
    ClearSurahSearch event,
    Emitter<QuranIndexState> emit,
  ) {
    if (state is! QuranIndexLoaded) {
      return;
    }

    final currentState = state as QuranIndexLoaded;

    emit(
      currentState.copyWith(
        filteredSurahs: _allSurahs,
      ),
    );
  }

// ==========================================================
// LOAD RECITERS
// ==========================================================

  Future<void> _onLoadReciters(
    LoadReciters event,
    Emitter<QuranIndexState> emit,
  ) async {
    try {
// ======================================================
// UseCase
// ======================================================

      final reciters = getQuranReciters();

      debugPrint(
        '🎧 Loaded ${reciters.length} reciters',
      );

      if (state is! QuranIndexLoaded) {
        return;
      }

      final currentState = state as QuranIndexLoaded;

      QuranReciter? selectedReciter = currentState.selectedReciter;

      if (selectedReciter == null && reciters.isNotEmpty) {
        selectedReciter = reciters.first;
      }

      emit(
        currentState.copyWith(
          reciters: reciters,
          selectedReciter: selectedReciter,
        ),
      );
    } catch (e, st) {
      debugPrint(
        '❌ Load reciters error: $e',
      );

      debugPrint('$st');

      emit(
        const QuranIndexError(
          'حدث خطأ أثناء تحميل القراء',
        ),
      );
    }
  }

// ==========================================================
// SELECT RECITER
// ==========================================================

  void _onSelectReciter(
      SelectReciter event,
      Emitter<QuranIndexState> emit,
      ) {
    if (state is! QuranIndexLoaded) {
      return;
    }

    final currentState = state as QuranIndexLoaded;

    if (currentState.reciters.isEmpty) {
      debugPrint('❌ No reciters available');
      return;
    }

    final selected = currentState.reciters
        .cast<QuranReciter?>()
        .firstWhere(
          (reciter) => reciter?.identifier == event.identifier,
      orElse: () => null,
    );

    if (selected == null) {
      debugPrint('❌ Reciter not found: ${event.identifier}');
      return;
    }

    debugPrint('🎙 Selected reciter: ${selected.identifier}');

    emit(
      currentState.copyWith(
        selectedReciter: selected,
        isPlaying: false,
        isPaused: false,
        clearPlayingAyah: true,
      ),
    );
  }


// ==========================================================
// PLAY AYAH
// ==========================================================

  Future<void> _onPlayAyah(
    PlayAyah event,
    Emitter<QuranIndexState> emit,
  ) async {
    try {
// ======================================================
// Current State
// ======================================================

      if (state is! QuranIndexLoaded) {
        return;
      }

      final currentState = state as QuranIndexLoaded;

// ======================================================
// Find Reciter
// ======================================================

      final reciters = currentState.reciters.isNotEmpty
          ? currentState.reciters
          : getQuranReciters();

      if (reciters.isEmpty) {
        debugPrint(
          '❌ No reciters available',
        );

        return;
      }

      final selected = reciters.firstWhere(
        (reciter) => reciter.identifier == event.reciterIdentifier,
        orElse: () => reciters.first,
      );

      debugPrint(
        '🎧 selected.identifier = '
        '"${selected.identifier}"',
      );

// ======================================================
// Get Audio URL through UseCase
// ======================================================

      final audioUrl = getAyahAudioUrl(
        reciterIdentifier: selected.identifier,
        globalAyahNumber: event.globalAyahNumber,
      );

      debugPrint(
        '🔊 Audio URL = $audioUrl',
      );

// ======================================================
// Play
// ======================================================

      await audioService.playUrl(
        audioUrl: audioUrl,
        reciterIdentifier: selected.identifier,
        globalAyahNumber: event.globalAyahNumber,
      );

// ======================================================
// Update State
// ======================================================

      emit(
        currentState.copyWith(
          reciters: reciters,
          selectedReciter: selected,
          isPlaying: true,
          isPaused: false,
          playingAyah: event.globalAyahNumber,
        ),
      );
    } catch (e, st) {
      debugPrint(
        '❌ Play ayah error: $e',
      );

      debugPrint('$st');

// مهم:
// لا نستبدل QuranIndexLoaded بـ Error
// حتى لا نخسر بيانات الفهرس.

      if (state is QuranIndexLoaded) {
        final currentState = state as QuranIndexLoaded;

        emit(
          currentState.copyWith(
            isPlaying: false,
            isPaused: false,
          ),
        );
      }
    }
  }

// ==========================================================
// PAUSE
// ==========================================================

  Future<void> _onPauseAyah(
    PauseAyah event,
    Emitter<QuranIndexState> emit,
  ) async {
    try {
      await audioService.pause();

      if (state is QuranIndexLoaded) {
        final currentState = state as QuranIndexLoaded;

        emit(
          currentState.copyWith(
            isPlaying: false,
            isPaused: true,
          ),
        );
      }
    } catch (e, st) {
      debugPrint(
        '❌ Pause error: $e',
      );

      debugPrint('$st');
    }
  }

// ==========================================================
// RESUME
// ==========================================================

  Future<void> _onResumeAyah(
    ResumeAyah event,
    Emitter<QuranIndexState> emit,
  ) async {
    try {
      await audioService.resume();

      if (state is QuranIndexLoaded) {
        final currentState = state as QuranIndexLoaded;

        emit(
          currentState.copyWith(
            isPlaying: true,
            isPaused: false,
          ),
        );
      }
    } catch (e, st) {
      debugPrint(
        '❌ Resume error: $e',
      );

      debugPrint('$st');
    }
  }

// ==========================================================
// STOP
// ==========================================================

  Future<void> _onStopAyah(
    StopAyah event,
    Emitter<QuranIndexState> emit,
  ) async {
    try {
      await audioService.stop();

      if (state is QuranIndexLoaded) {
        final currentState = state as QuranIndexLoaded;

        emit(
          currentState.copyWith(
            isPlaying: false,
            isPaused: false,
            clearPlayingAyah: true,
          ),
        );
      }
    } catch (e, st) {
      debugPrint(
        '❌ Stop error: $e',
      );

      debugPrint('$st');
    }
  }

// ==========================================================
// CLOSE
// ==========================================================

  @override
  Future<void> close() async {
    await audioService.dispose();

    return super.close();
  }
}
