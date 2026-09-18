import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/features/quran/presentation/bloc/quran_event.dart';
import 'package:islamic_app/features/quran/presentation/bloc/quran_state.dart';

import '../../../../core/errors/no_internet_exception.dart';
import '../../../../core/services/ayah_audio_service.dart';

import '../../../../core/utils/internet_checker.dart';
import '../../domain/entities/quran_tafsir_book.dart';
import '../../domain/entities/surah_entity.dart';
import '../../domain/entities/quran_reciter.dart';

import '../../domain/usecases/ get_ayah_audio_url.dart';
import '../../domain/usecases/GetAyahTafsir.dart';
import '../../domain/usecases/get_surahs.dart';
import '../../domain/usecases/search_surahs.dart';
import '../../domain/usecases/get_quran_reciters.dart';

import '../../domain/usecases/get_tafsir_books.dart';

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
  // Tafsir UseCases
  // ==========================================================

  final GetTafsirBooks getTafsirBooks;
  final GetAyahTafsir getAyahTafsir;

  // ==========================================================
  // Audio Service
  // ==========================================================

  final AyahAudioService audioService;

  // ==========================================================
  // No Internet (حدث لمرة واحدة، لا يُخزَّن في الـ State)
  // ==========================================================

  final StreamController<String> _noInternetController =
  StreamController<String>.broadcast();

  Stream<String> get noInternetStream => _noInternetController.stream;

  String? _pendingNoInternetMessage;

  void _emitNoInternet(String message, {bool keepPending = true}) {
    debugPrint(
      '📵 NoInternet, hasListener=${_noInternetController.hasListener}',
    );

    if (_noInternetController.hasListener) {
      _noInternetController.add(message);
    } else if (keepPending) {
      // لا يوجد مستمع بعد، نحتفظ بالرسالة حتى يشترك أحد
      _pendingNoInternetMessage = message;
    }
  }

  String? takePendingNoInternet() {
    final message = _pendingNoInternetMessage;
    _pendingNoInternetMessage = null;
    return message;
  }

  // ==========================================================
  // Constructor
  // ==========================================================

  QuranIndexBloc({
    required this.getSurahs,
    required this.searchSurahs,
    required this.getQuranReciters,
    required this.getAyahAudioUrl,
    required this.getTafsirBooks,
    required this.getAyahTafsir,
    required this.audioService,
  }) : super(const QuranIndexInitial()) {
    // Surah
    on<LoadSurahs>(_onLoadSurahs);
    on<SearchSurahsEvent>(_onSearchSurahs);
    on<ClearSurahSearch>(_onClearSearch);

    // Audio
    on<LoadReciters>(_onLoadReciters);
    on<SelectReciter>(_onSelectReciter);

    on<PlayAyah>(_onPlayAyah);
    on<PauseAyah>(_onPauseAyah);
    on<ResumeAyah>(_onResumeAyah);
    on<StopAyah>(_onStopAyah);

    // Tafsir
    on<LoadTafsirBooks>(_onLoadTafsirBooks);
    on<SelectTafsirBook>(_onSelectTafsirBook);
    on<LoadAyahTafsir>(_onLoadAyahTafsir);
    on<ClearAyahTafsir>(_onClearAyahTafsir);
  }

  // ==========================================================
  // LOAD SURAHS
  // ==========================================================

  Future<void> _onLoadSurahs(
      LoadSurahs event,
      Emitter<QuranIndexState> emit,
      ) async {
    debugPrint('🟢 _onLoadSurahs called');
    debugPrint('   _allSurahs.length = ${_allSurahs.length}');

    // Cache
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

    // Loading
    emit(const QuranIndexLoading());
    debugPrint('   ⏳ loading...');

    try {
      final result = await getSurahs();

      debugPrint('   📚 getSurahs returned ${result.length} surahs');

      _allSurahs = result;

      final reciters = getQuranReciters();

      debugPrint('   🎧 reciters = ${reciters.length}');
      debugPrint(
        '   🎧 first = '
            '${reciters.isNotEmpty ? reciters.first.identifier : "NONE"}',
      );

      emit(
        QuranIndexLoaded(
          allSurahs: result,
          filteredSurahs: result,
          reciters: reciters,
          selectedReciter: reciters.isNotEmpty ? reciters.first : null,
        ),
      );

      debugPrint('   ✅ QuranIndexLoaded emitted');
    } catch (e, st) {
      debugPrint('   ❌ Error: $e');
      debugPrint('$st');

      emit(const QuranIndexError('حدث خطأ أثناء تحميل فهرس القرآن'));
    }
  }

  // ==========================================================
  // SEARCH
  // ==========================================================

  void _onSearchSurahs(
      SearchSurahsEvent event,
      Emitter<QuranIndexState> emit,
      ) {
    if (state is! QuranIndexLoaded) return;

    final currentState = state as QuranIndexLoaded;

    final result = searchSurahs(_allSurahs, event.query);

    emit(currentState.copyWith(filteredSurahs: result));
  }

  // ==========================================================
  // CLEAR SEARCH
  // ==========================================================

  void _onClearSearch(
      ClearSurahSearch event,
      Emitter<QuranIndexState> emit,
      ) {
    if (state is! QuranIndexLoaded) return;

    final currentState = state as QuranIndexLoaded;

    emit(currentState.copyWith(filteredSurahs: _allSurahs));
  }

  // ==========================================================
  // LOAD RECITERS
  // ==========================================================

  Future<void> _onLoadReciters(
      LoadReciters event,
      Emitter<QuranIndexState> emit,
      ) async {
    try {
      final reciters = getQuranReciters();

      debugPrint('🎧 Loaded ${reciters.length} reciters');

      if (state is! QuranIndexLoaded) return;

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
      debugPrint('❌ Load reciters error: $e');
      debugPrint('$st');

      emit(const QuranIndexError('حدث خطأ أثناء تحميل القراء'));
    }
  }

  // ==========================================================
  // SELECT RECITER
  // ==========================================================

  void _onSelectReciter(
      SelectReciter event,
      Emitter<QuranIndexState> emit,
      ) {
    if (state is! QuranIndexLoaded) return;

    final currentState = state as QuranIndexLoaded;

    if (currentState.reciters.isEmpty) {
      debugPrint('❌ No reciters available');
      return;
    }

    final selected = currentState.reciters.cast<QuranReciter?>().firstWhere(
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
      if (state is! QuranIndexLoaded) return;

      final currentState = state as QuranIndexLoaded;

      // ------------------------------------------------------
      // فحص الإنترنت قبل التشغيل
      // ------------------------------------------------------

      final online = await InternetChecker.hasInternet();

      if (!online) {
        debugPrint('📵 No internet, skip playing ayah');

        _emitNoInternet(
          'لا يوجد اتصال بالإنترنت',
          keepPending: false,
        );

        return;
      }

      final reciters = currentState.reciters.isNotEmpty
          ? currentState.reciters
          : getQuranReciters();

      if (reciters.isEmpty) {
        debugPrint('❌ No reciters available');
        return;
      }

      final selected = reciters.firstWhere(
            (reciter) => reciter.identifier == event.reciterIdentifier,
        orElse: () => reciters.first,
      );

      debugPrint('🎧 selected.identifier = "${selected.identifier}"');

      final audioUrl = getAyahAudioUrl(
        reciterIdentifier: selected.identifier,
        globalAyahNumber: event.globalAyahNumber,
      );

      debugPrint('🔊 Audio URL = $audioUrl');

      await audioService.playUrl(
        audioUrl: audioUrl,
        reciterIdentifier: selected.identifier,
        globalAyahNumber: event.globalAyahNumber,
      );

      // الحالة الأحدث بعد الـ await
      if (state is! QuranIndexLoaded) return;

      emit(
        (state as QuranIndexLoaded).copyWith(
          reciters: reciters,
          selectedReciter: selected,
          isPlaying: true,
          isPaused: false,
          playingAyah: event.globalAyahNumber,
        ),
      );
    } catch (e, st) {
      debugPrint('❌ Play ayah error: $e');
      debugPrint('$st');

      // لا نستبدل QuranIndexLoaded بـ Error
      // حتى لا نخسر بيانات الفهرس والتفسير.
      if (state is QuranIndexLoaded) {
        emit(
          (state as QuranIndexLoaded).copyWith(
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
      debugPrint('❌ Pause error: $e');
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
      debugPrint('❌ Resume error: $e');
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
      debugPrint('❌ Stop error: $e');
      debugPrint('$st');
    }
  }

  // ==========================================================
  // LOAD TAFSIR BOOKS
  // ==========================================================

  Future<void> _onLoadTafsirBooks(
      LoadTafsirBooks event,
      Emitter<QuranIndexState> emit,
      ) async {
    if (state is! QuranIndexLoaded) return;

    final startState = state as QuranIndexLoaded;

    // الكتب محملة ومعه كتاب مختار: نحافظ على اختيار المستخدم
    if (startState.tafsirBooks.isNotEmpty &&
        startState.selectedTafsirBook != null) {
      return;
    }

    try {
      debugPrint('📚 Loading tafsir books for surah ${event.surahNumber}');

      emit(startState.copyWith(isTafsirLoading: true));

      final books = await getTafsirBooks(surahNumber: event.surahNumber);

      debugPrint('📚 Loaded ${books.length} tafsir books');

      // نقرأ الحالة الأحدث بعد الـ await
      if (state is! QuranIndexLoaded) return;
      final latest = state as QuranIndexLoaded;

      // نحافظ على الكتاب المختار سابقًا لو موجود، وإلا نختار الأول (الافتراضي)
      QuranTafsirBook? selected;
      for (final b in books) {
        if (b.id == latest.selectedTafsirBook?.id) {
          selected = b;
          break;
        }
      }
      selected ??= books.isNotEmpty ? books.first : null;

      emit(
        latest.copyWith(
          tafsirBooks: books,
          selectedTafsirBook: selected,
          isTafsirLoading: false,
        ),
      );
    } catch (e, st) {
      debugPrint('❌ Load tafsir books error: $e');
      debugPrint('$st');

      if (e is NoInternetException) {
        _emitNoInternet(e.message);
      }

      // نحافظ على QuranIndexLoaded ولا نحوله إلى QuranIndexError
      if (state is QuranIndexLoaded) {
        emit((state as QuranIndexLoaded).copyWith(isTafsirLoading: false));
      }
    }
  }

  // ==========================================================
  // SELECT TAFSIR BOOK
  // ==========================================================

  Future<void> _onSelectTafsirBook(
      SelectTafsirBook event,
      Emitter<QuranIndexState> emit,
      ) async {
    if (state is! QuranIndexLoaded) return;

    final currentState = state as QuranIndexLoaded;

    if (currentState.tafsirBooks.isEmpty) {
      debugPrint('❌ No tafsir books available');
      return;
    }

    QuranTafsirBook? selectedBook;

    for (final book in currentState.tafsirBooks) {
      if (book.id == event.bookId) {
        selectedBook = book;
        break;
      }
    }

    if (selectedBook == null) {
      debugPrint('❌ Tafsir book not found: ${event.bookId}');
      return;
    }

    debugPrint('📖 Selected tafsir book: ${selectedBook.name}');

    emit(
      currentState.copyWith(
        selectedTafsirBook: selectedBook,
        clearAyahTafsir: true,
      ),
    );
  }

  // ==========================================================
  // LOAD AYAH TAFSIR
  // ==========================================================

  Future<void> _onLoadAyahTafsir(
      LoadAyahTafsir event,
      Emitter<QuranIndexState> emit,
      ) async {
    if (state is! QuranIndexLoaded) return;

    var currentState = state as QuranIndexLoaded;

    try {
      // ------------------------------------------------------
      // لو مفيش كتاب مختار: نحمّل الكتب ونختار الافتراضي
      // ------------------------------------------------------

      var selectedBook = currentState.selectedTafsirBook;

      if (selectedBook == null) {
        emit(currentState.copyWith(isTafsirLoading: true));

        final books = await getTafsirBooks(surahNumber: event.surahNumber);

        if (books.isEmpty) {
          debugPrint('❌ No tafsir books available');

          if (state is QuranIndexLoaded) {
            emit((state as QuranIndexLoaded).copyWith(isTafsirLoading: false));
          }
          return;
        }

        selectedBook = books.first;

        if (state is! QuranIndexLoaded) return;
        currentState = state as QuranIndexLoaded;

        emit(
          currentState.copyWith(
            tafsirBooks: books,
            selectedTafsirBook: selectedBook,
          ),
        );
      }

      debugPrint(
        '📖 Loading tafsir ${event.surahNumber}:${event.ayahNumber} '
            'book=${selectedBook.id}',
      );

      if (state is! QuranIndexLoaded) return;
      currentState = state as QuranIndexLoaded;

      emit(
        currentState.copyWith(
          isTafsirLoading: true,
          clearAyahTafsir: true,
        ),
      );

      final tafsir = await getAyahTafsir(
        surahNumber: event.surahNumber,
        ayahNumber: event.ayahNumber,
        bookId: selectedBook.id,
      );

      debugPrint(
        tafsir == null
            ? '⚠️ No tafsir found for ${event.surahNumber}:${event.ayahNumber}'
            : '✅ Tafsir loaded for ${event.surahNumber}:${event.ayahNumber}',
      );

      // الحالة الأحدث بعد الـ await
      if (state is! QuranIndexLoaded) return;
      final latest = state as QuranIndexLoaded;

      emit(
        latest.copyWith(
          ayahTafsir: tafsir,
          isTafsirLoading: false,
        ),
      );
    } catch (e, st) {
      debugPrint('❌ Load ayah tafsir error: $e');
      debugPrint('$st');

      if (e is NoInternetException) {
        _emitNoInternet(e.message);
      }

      if (state is QuranIndexLoaded) {
        emit((state as QuranIndexLoaded).copyWith(isTafsirLoading: false));
      }
    }
  }

  // ==========================================================
  // CLEAR AYAH TAFSIR
  // ==========================================================

  void _onClearAyahTafsir(
      ClearAyahTafsir event,
      Emitter<QuranIndexState> emit,
      ) {
    if (state is! QuranIndexLoaded) return;

    final currentState = state as QuranIndexLoaded;

    emit(currentState.copyWith(clearAyahTafsir: true));
  }

  // ==========================================================
  // CLOSE
  // ==========================================================

  @override
  Future<void> close() async {
    await _noInternetController.close();
    await audioService.dispose();

    return super.close();
  }
}