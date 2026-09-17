class Surah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameTranslation;
  final int ayahCount;
  final double headerPosition;
  final int juzNumber;
  final int pageNumber;

  const Surah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameTranslation,
    required this.ayahCount,
    required this.headerPosition,
    required this.juzNumber,
    required this.pageNumber,
  });
}