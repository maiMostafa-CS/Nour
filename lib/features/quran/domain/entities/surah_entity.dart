import 'package:equatable/equatable.dart';

class SurahEntity extends Equatable {
  final int number;
  final String name;
  final String englishName;
  final int startPage;
  final int totalAyahs;

  const SurahEntity({
    required this.number,
    required this.name,
    required this.englishName,
    required this.startPage,
    required this.totalAyahs,
  });

  @override
  List<Object?> get props => [
    number,
    name,
    englishName,
    startPage,
    totalAyahs,
  ];
}

class AyahEntity extends Equatable {
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final String? translation;
  final int juz;
  final int? hizb;
  final int? rub;
  final int page;
  final int? ruku;

  const AyahEntity({
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    this.translation,
    required this.juz,
    this.hizb,
    this.rub,
    required this.page,
    this.ruku,
  });

  @override
  List<Object?> get props => [
    surahNumber,
    ayahNumber,
    text,
    translation,
    juz,
    hizb,
    rub,
    page,
    ruku,
  ];
}

class PageEntity extends Equatable {
  final int pageNumber;
  final List<AyahEntity> ayahs;

  const PageEntity({
    required this.pageNumber,
    required this.ayahs,
  });

  @override
  List<Object?> get props => [
    pageNumber,
    ayahs,
  ];
}