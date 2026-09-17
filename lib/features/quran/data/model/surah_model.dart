import '../../domain/entities/surah_entity.dart';

class SurahModel extends Surah {
  const SurahModel({
    required super.number,
    required super.nameArabic,
    required super.nameEnglish,
    required super.nameTranslation,
    required super.ayahCount,
    required super.headerPosition,
    required super.juzNumber,
    required super.pageNumber,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: (json['number'] as num).toInt(),
      nameArabic: json['nameArabic']?.toString() ?? '',
      nameEnglish: json['nameEnglish']?.toString() ?? '',
      nameTranslation: json['nameTranslation']?.toString() ?? '',
      ayahCount: (json['ayahCount'] as num).toInt(),
      headerPosition: (json['headerPosition'] as num).toDouble(),
      juzNumber: (json['juzNumber'] as num).toInt(),
      pageNumber: (json['pageNumber'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'nameArabic': nameArabic,
      'nameEnglish': nameEnglish,
      'nameTranslation': nameTranslation,
      'ayahCount': ayahCount,
      'headerPosition': headerPosition,
      'juzNumber': juzNumber,
      'pageNumber': pageNumber,
    };
  }
}