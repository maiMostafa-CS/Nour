import 'package:equatable/equatable.dart';

import '../../domain/entities/quran_reciter.dart';
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

  const QuranIndexLoaded({
    required this.allSurahs,
    required this.filteredSurahs,
    this.reciters = const [],
    this.selectedReciter,
    this.isPlaying = false,
    this.isPaused = false,
    this.playingAyah,
  });

  QuranIndexLoaded copyWith({
    List<Surah>? allSurahs,
    List<Surah>? filteredSurahs,
    List<QuranReciter>? reciters,
    QuranReciter? selectedReciter,
    bool? isPlaying,
    bool? isPaused,
    int? playingAyah,

// يستخدم عندما نريد مسح الآية الحالية
    bool clearPlayingAyah = false,

// يستخدم عندما نريد مسح القارئ
    bool clearSelectedReciter = false,
  }) {
    return QuranIndexLoaded(
      allSurahs: allSurahs ?? this.allSurahs,
      filteredSurahs: filteredSurahs ?? this.filteredSurahs,
      reciters: reciters ?? this.reciters,
      selectedReciter:
          clearSelectedReciter ? null : selectedReciter ?? this.selectedReciter,
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      playingAyah: clearPlayingAyah ? null : playingAyah ?? this.playingAyah,
    );
  }

  @override
  List<Object?> get props => [
        allSurahs,
        filteredSurahs,
        reciters,
        selectedReciter,
        isPlaying,
        isPaused,
        playingAyah,
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
