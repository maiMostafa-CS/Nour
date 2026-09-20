import 'package:qcf_quran/qcf_quran.dart';

class KhatmaAyah {
  final int globalNumber;
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String text;
  final int pageNumber;

  const KhatmaAyah({
    required this.globalNumber,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.text,
    required this.pageNumber,
  });
}

class KhatmaAyahResolver {
  // Standard Madani/Uthmani ayah counts used by qcf_quran's 6236-ayah dataset.
  static const List<int> _counts = [
    7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99,
    128, 111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34,
    30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18,
    45, 37, 26, 62, 49, 98, 30, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12,
    30, 52, 52, 44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25,
    22, 17, 19, 26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9,
    5, 4, 7, 3, 6, 3, 5, 4, 5, 6
  ];

  static KhatmaAyah resolve(int globalNumber) {
    if (globalNumber < 1 || globalNumber > 6236) {
      throw ArgumentError.value(globalNumber, 'globalNumber');
    }

    var remaining = globalNumber;

    for (var surah = 1; surah <= 114; surah++) {
      final count = _counts[surah - 1];
      if (remaining <= count) {
        final ayah = remaining;
        return KhatmaAyah(
          globalNumber: globalNumber,
          surahNumber: surah,
          ayahNumber: ayah,
          surahName: getSurahNameArabic(surah),
          text: "  ${getVerse(surah, ayah)}",
          pageNumber: getPageNumber(surah, ayah),
        );
      }
      remaining -= count;
    }

    throw StateError('Unable to resolve Quran ayah $globalNumber');
  }
}
