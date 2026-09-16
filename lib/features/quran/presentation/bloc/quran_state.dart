part of 'quran_bloc.dart';

sealed class QuranState extends Equatable {
  const QuranState();
}

class QuranInitial extends QuranState {
  const QuranInitial();

  @override
  List<Object?> get props => [];
}

class QuranLoading extends QuranState {
  const QuranLoading();

  @override
  List<Object?> get props => [];
}

// ============================================================
// السور
// ============================================================

class QuranLoaded extends QuranState {
  final List<SurahEntity> surahs;

  const QuranLoaded(this.surahs);

  @override
  List<Object?> get props => [surahs];
}

// ============================================================
// تحميل صفحة
// ============================================================

class QuranPageLoading extends QuranState {
  final int pageNumber;

  const QuranPageLoading({
    required this.pageNumber,
  });

  @override
  List<Object?> get props => [pageNumber];
}

// ============================================================
// الصفحة تم تحميلها
// ============================================================

class QuranPageLoaded extends QuranState {
  final PageEntity page;

  const QuranPageLoaded(this.page);

  @override
  List<Object?> get props => [page];
}

// ============================================================
// خطأ
// ============================================================

class QuranError extends QuranState {
  final String message;

  const QuranError(this.message);

  @override
  List<Object?> get props => [message];
}