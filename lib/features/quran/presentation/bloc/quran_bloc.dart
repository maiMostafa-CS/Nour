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

import '../../domain/usecases/GetAyahTafsir.dart';
import '../../domain/usecases/get_ayah_audio_url.dart';
import '../../domain/usecases/get_ayah_translation.dart';
import '../../domain/usecases/get_quran_reciters.dart';
import '../../domain/usecases/get_surahs.dart';
import '../../domain/usecases/get_tafsir_books.dart';
import '../../domain/usecases/get_translation_resources.dart';
import '../../domain/usecases/search_surahs.dart';
import '../../domain/entities/quran_translation_resource.dart';

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
  // Translation UseCases
  // ==========================================================

  final GetTranslationResources getTranslationResources;
  final GetAyahTranslation getAyahTranslation;

  // ==========================================================
  // Audio Service
  // ==========================================================

  final AyahAudioService audioService;

  // ==========================================================
  // No Internet (handled once; not stored in the State)
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
      // No listener yet; keep the message until a listener subscribes
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
    required this.getTranslationResources,
    required this.getAyahTranslation,
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

    // Translation
    on<LoadTranslationResources>(_onLoadTranslationResources);
    on<SelectTranslationResource>(_onSelectTranslationResource);
    on<LoadAyahTranslation>(_onLoadAyahTranslation);
    on<ClearAyahTranslation>(_onClearAyahTranslation);
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
      // Check internet connection
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

      // ------------------------------------------------------
      // Reciters
      // ------------------------------------------------------

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

      debugPrint(
        '🎧 selected.identifier = "${selected.identifier}"',
      );

      final audioUrl = getAyahAudioUrl(
        reciterIdentifier: selected.identifier,
        globalAyahNumber: event.globalAyahNumber,
      );

      debugPrint('🔊 Audio URL = $audioUrl');

      // ======================================================
      // ⭐ Most important change
      // Change the UI state before starting audio
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

      // ======================================================
      // Start audio
      // ======================================================

      await audioService.playUrl(
        audioUrl: audioUrl,
        reciterIdentifier: selected.identifier,
        globalAyahNumber: event.globalAyahNumber,
      );

    } catch (e, st) {
      debugPrint('❌ Play ayah error: $e');
      debugPrint('$st');

      // If playback fails, restore the icon to Play
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

    // Books are loaded and a book is selected: preserve the user's selection
    if (startState.tafsirBooks.isNotEmpty &&
        startState.selectedTafsirBook != null) {
      return;
    }

    try {
      debugPrint('📚 Loading tafsir books for surah ${event.surahNumber}');

      emit(startState.copyWith(isTafsirLoading: true));

      final books = await getTafsirBooks(surahNumber: event.surahNumber);

      debugPrint('📚 Loaded ${books.length} tafsir books');

      // Read the latest state after await
      if (state is! QuranIndexLoaded) return;
      final latest = state as QuranIndexLoaded;

      // Keep the previously selected book if available; otherwise select the first one (default)
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

      // Keep QuranIndexLoaded and do not change it to QuranIndexError
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
      // If no book is selected: load the books and select the default
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

      // Latest state after await
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
  // LOAD TRANSLATION RESOURCES
  // ==========================================================

  Future<void> _onLoadTranslationResources(
    LoadTranslationResources event,
    Emitter<QuranIndexState> emit,
  ) async {
    if (state is! QuranIndexLoaded) return;
    final startState = state as QuranIndexLoaded;

    try {
      debugPrint('🌍 Loading translation resources for ${event.language}');

      emit(startState.copyWith(isTranslationLoading: true));

      final resources = await getTranslationResources(
        language: event.language,
      );

      debugPrint('🌍 Loaded ${resources.length} translation resources');

      if (state is! QuranIndexLoaded) return;
      final latest = state as QuranIndexLoaded;

      QuranTranslationResource? selected;
      for (final r in resources) {
        if (r.id == latest.selectedTranslationResource?.id) {
          selected = r;
          break;
        }
      }
      // Prefer Saheeh International (id 20) as default, otherwise first available
      selected ??= resources.firstWhere(
        (r) => r.id == 20,
        orElse: () => resources.isNotEmpty ? resources.first : const QuranTranslationResource(
          id: 20,
          name: 'Saheeh International',
          authorName: 'Saheeh International',
          languageName: 'english',
        ),
      );

      emit(
        latest.copyWith(
          translationResources: resources,
          selectedTranslationResource: selected,
          isTranslationLoading: false,
        ),
      );
    } catch (e, st) {
      debugPrint('❌ Load translation resources error: $e\n$st');

      if (e is NoInternetException) {
        _emitNoInternet(e.message);
      }

      if (state is QuranIndexLoaded) {
        emit((state as QuranIndexLoaded).copyWith(isTranslationLoading: false));
      }
    }
  }

  // ==========================================================
  // SELECT TRANSLATION RESOURCE
  // ==========================================================

  Future<void> _onSelectTranslationResource(
    SelectTranslationResource event,
    Emitter<QuranIndexState> emit,
  ) async {
    if (state is! QuranIndexLoaded) return;

    final currentState = state as QuranIndexLoaded;

    if (currentState.translationResources.isEmpty) {
      debugPrint('❌ No translation resources available');
      return;
    }

    QuranTranslationResource? selectedResource;
    for (final resource in currentState.translationResources) {
      if (resource.id == event.resourceId) {
        selectedResource = resource;
        break;
      }
    }

    if (selectedResource == null) {
      debugPrint('❌ Translation resource not found: ${event.resourceId}');
      return;
    }

    debugPrint('📖 Selected translation resource: ${selectedResource.name}');

    emit(
      currentState.copyWith(
        selectedTranslationResource: selectedResource,
        clearAyahTranslation: true,
      ),
    );
  }

  // ==========================================================
  // LOAD AYAH TRANSLATION
  // ==========================================================

  Future<void> _onLoadAyahTranslation(
    LoadAyahTranslation event,
    Emitter<QuranIndexState> emit,
  ) async {
    if (state is! QuranIndexLoaded) return;

    var currentState = state as QuranIndexLoaded;

    try {
      var selectedResource = currentState.selectedTranslationResource;

      if (selectedResource == null) {
        emit(currentState.copyWith(isTranslationLoading: true));

        final resources = await getTranslationResources();

        if (resources.isEmpty) {
          debugPrint('❌ No translation resources available');
          if (state is QuranIndexLoaded) {
            emit((state as QuranIndexLoaded).copyWith(isTranslationLoading: false));
          }
          return;
        }

        selectedResource = resources.firstWhere(
          (r) => r.id == 20,
          orElse: () => resources.first,
        );

        if (state is! QuranIndexLoaded) return;
        currentState = state as QuranIndexLoaded;

        emit(
          currentState.copyWith(
            translationResources: resources,
            selectedTranslationResource: selectedResource,
          ),
        );
      }

      debugPrint(
        '🌍 Loading translation ${event.surahNumber}:${event.ayahNumber} '
        'resource=${selectedResource.id}',
      );

      if (state is! QuranIndexLoaded) return;
      currentState = state as QuranIndexLoaded;

      emit(
        currentState.copyWith(
          isTranslationLoading: true,
          clearAyahTranslation: true,
        ),
      );

      final translation = await getAyahTranslation(
        surahNumber: event.surahNumber,
        ayahNumber: event.ayahNumber,
        resourceId: selectedResource.id,
      );

      debugPrint(
        translation == null
            ? '⚠️ No translation found for ${event.surahNumber}:${event.ayahNumber}'
            : '✅ Translation loaded for ${event.surahNumber}:${event.ayahNumber}',
      );

      if (state is! QuranIndexLoaded) return;
      final latest = state as QuranIndexLoaded;

      emit(
        latest.copyWith(
          ayahTranslation: translation,
          isTranslationLoading: false,
        ),
      );
    } catch (e, st) {
      debugPrint('❌ Load ayah translation error: $e\n$st');

      if (e is NoInternetException) {
        _emitNoInternet(e.message);
      }

      if (state is QuranIndexLoaded) {
        emit((state as QuranIndexLoaded).copyWith(isTranslationLoading: false));
      }
    }
  }

  // ==========================================================
  // CLEAR AYAH TRANSLATION
  // ==========================================================

  void _onClearAyahTranslation(
    ClearAyahTranslation event,
    Emitter<QuranIndexState> emit,
  ) {
    if (state is! QuranIndexLoaded) return;

    final currentState = state as QuranIndexLoaded;

    emit(currentState.copyWith(clearAyahTranslation: true));
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