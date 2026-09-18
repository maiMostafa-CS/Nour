import '../../domain/entities/quran_tafsir.dart';

class QuranTafsirModel extends QuranTafsir {
  const QuranTafsirModel({
    required super.bookId,
    required super.bookName,
    super.author,
    required super.text,
  });

  factory QuranTafsirModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final book = json['book'] is Map
        ? Map<String, dynamic>.from(json['book'])
        : <String, dynamic>{};

    final content = json['content'] is List
        ? json['content'] as List
        : <dynamic>[];

    final texts = content
        .whereType<Map>()
        .map(
          (item) => item['text']?.toString() ?? '',
    )
        .where(
          (text) => text.trim().isNotEmpty,
    )
        .toList();

    return QuranTafsirModel(
      bookId: (book['id'] as num?)?.toInt() ?? 0,
      bookName: book['name']?.toString() ?? '',
      author: book['author'] is Map
          ? (
          book['author']['full_name']?.toString() ??
              book['author']['ar_name']?.toString()
      )
          : book['author']?.toString(),
      text: texts.join('\n\n'),
    );
  }
}