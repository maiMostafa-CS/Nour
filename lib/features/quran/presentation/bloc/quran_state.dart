import 'package:equatable/equatable.dart';

import '../../domain/entities/quran_reciter.dart';
import '../../domain/entities/quran_tafsir.dart';
import '../../domain/entities/quran_tafsir_book.dart';
import '../../domain/entities/quran_translation.dart';
import '../../domain/entities/quran_translation_resource.dart';
import '../../domain/entities/surah_entity.dart';

/// ============================================================
/// Base State
/// ============================================================

abstract class QuranIndexState extends Equatable {
  const QuranIndexState();

  @override
  List<Object?> get props => [];
}

/// ============================================================
/// Initial
/// ============================================================

class QuranIndexInitial extends QuranIndexState {
  const QuranIndexInitial();
}

/// ============================================================
/// Loading
/// ============================================================

class QuranIndexLoading extends QuranIndexState {
  const QuranIndexLoading();
}

/// ============================================================
/// Loaded
/// ============================================================

class QuranIndexLoaded extends QuranIndexState {
  // ==========================================================
  // Surahs
  // ==========================================================

  final List<Surah> allSurahs;
  final List<Surah> filteredSurahs;

  // ==========================================================
  // Audio
  // ==========================================================

  final List<QuranReciter> reciters;
  final QuranReciter? selectedReciter;

  final bool isPlaying;
  final bool isPaused;

  final int? playingAyah;

  // ==========================================================
  // Tafsir
  // ==========================================================

  final List<QuranTafsirBook> tafsirBooks;
  final QuranTafsirBook? selectedTafsirBook;

  final QuranTafsir? ayahTafsir;

  final bool isTafsirLoading;

  // ==========================================================
  // Translation
  // ==========================================================

  final List<QuranTranslationResource> translationResources;
  final QuranTranslationResource? selectedTranslationResource;

  final QuranTranslation? ayahTranslation;

  final bool isTranslationLoading;

  // ==========================================================
  // Constructor
  // ==========================================================

  const QuranIndexLoaded({
    required this.allSurahs,
    required this.filteredSurahs,

    // Audio
    this.reciters = const [],
    this.selectedReciter,
    this.isPlaying = false,
    this.isPaused = false,
    this.playingAyah,

    // Tafsir
    this.tafsirBooks = const [],
    this.selectedTafsirBook,
    this.ayahTafsir,
    this.isTafsirLoading = false,

    // Translation
    this.translationResources = const [],
    this.selectedTranslationResource,
    this.ayahTranslation,
    this.isTranslationLoading = false,
  });

  // ==========================================================
  // Copy With
  // ==========================================================

  QuranIndexLoaded copyWith({
    // Surahs
    List<Surah>? allSurahs,
    List<Surah>? filteredSurahs,

    // Audio
    List<QuranReciter>? reciters,
    QuranReciter? selectedReciter,
    bool? isPlaying,
    bool? isPaused,
    int? playingAyah,

    bool clearPlayingAyah = false,
    bool clearSelectedReciter = false,

    // Tafsir
    List<QuranTafsirBook>? tafsirBooks,
    QuranTafsirBook? selectedTafsirBook,
    QuranTafsir? ayahTafsir,
    bool? isTafsirLoading,

    bool clearSelectedTafsirBook = false,
    bool clearAyahTafsir = false,

    // Translation
    List<QuranTranslationResource>? translationResources,
    QuranTranslationResource? selectedTranslationResource,
    QuranTranslation? ayahTranslation,
    bool? isTranslationLoading,

    bool clearSelectedTranslationResource = false,
    bool clearAyahTranslation = false,
  }) {
    return QuranIndexLoaded(
      // ======================================================
      // Surahs
      // ======================================================

      allSurahs: allSurahs ?? this.allSurahs,
      filteredSurahs: filteredSurahs ?? this.filteredSurahs,

      // ======================================================
      // Audio
      // ======================================================

      reciters: reciters ?? this.reciters,

      selectedReciter: clearSelectedReciter
          ? null
          : selectedReciter ?? this.selectedReciter,

      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,

      playingAyah: clearPlayingAyah
          ? null
          : playingAyah ?? this.playingAyah,

      // ======================================================
      // Tafsir
      // ======================================================

      tafsirBooks: tafsirBooks ?? this.tafsirBooks,

      selectedTafsirBook: clearSelectedTafsirBook
          ? null
          : selectedTafsirBook ?? this.selectedTafsirBook,

      ayahTafsir: clearAyahTafsir
          ? null
          : ayahTafsir ?? this.ayahTafsir,

      isTafsirLoading:
      isTafsirLoading ?? this.isTafsirLoading,

      // ======================================================
      // Translation
      // ======================================================

      translationResources:
          translationResources ?? this.translationResources,

      selectedTranslationResource: clearSelectedTranslationResource
          ? null
          : selectedTranslationResource ?? this.selectedTranslationResource,

      ayahTranslation: clearAyahTranslation
          ? null
          : ayahTranslation ?? this.ayahTranslation,

      isTranslationLoading:
          isTranslationLoading ?? this.isTranslationLoading,
    );
  }

  // ==========================================================
  // Equatable
  // ==========================================================

  @override
  List<Object?> get props => [
    // Surahs
    allSurahs,
    filteredSurahs,

    // Audio
    reciters,
    selectedReciter,
    isPlaying,
    isPaused,
    playingAyah,

    // Tafsir
    tafsirBooks,
    selectedTafsirBook,
    ayahTafsir,
    isTafsirLoading,

    // Translation
    translationResources,
    selectedTranslationResource,
    ayahTranslation,
    isTranslationLoading,
  ];
}

/// ============================================================
/// Error
/// ============================================================

class QuranIndexError extends QuranIndexState {
  final String message;

  const QuranIndexError(this.message);

  @override
  List<Object?> get props => [message];
}