import '../../domain/entities/quran_tafsir_book.dart';

class QuranTafsirBookModel extends QuranTafsirBook {
  const QuranTafsirBookModel({
    required super.id,
    required super.name,
    super.author,
  });

  factory QuranTafsirBookModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return QuranTafsirBookModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      author: json['author']?.toString(),
    );
  }
}