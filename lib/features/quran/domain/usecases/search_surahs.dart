import '../entities/surah_entity.dart';

class SearchSurahs {
  const SearchSurahs();

  List<Surah> call(
      List<Surah> surahs,
      String query,
      ) {
    final String normalizedQuery =
    query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return List<Surah>.from(surahs);
    }

    return surahs.where((surah) {
      final String arabicName =
      surah.nameArabic.trim();

      final String englishName =
      surah.nameEnglish.trim().toLowerCase();

      final String translation =
      surah.nameTranslation.trim().toLowerCase();

      final String number =
      surah.number.toString();

      return arabicName.contains(normalizedQuery) ||
          englishName.contains(normalizedQuery) ||
          translation.contains(normalizedQuery) ||
          number == normalizedQuery;
    }).toList();
  }
}