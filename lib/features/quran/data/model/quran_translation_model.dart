import '../../domain/entities/quran_translation.dart';

class QuranTranslationModel extends QuranTranslation {
  const QuranTranslationModel({
    required super.resourceId,
    required super.translationName,
    required super.authorName,
    required super.text,
    super.ayahNumber,
  });

  factory QuranTranslationModel.fromJson({
    required Map<String, dynamic> json,
    required int resourceId,
    String? fallbackName,
    String? fallbackAuthor,
    int? ayahNumber,
  }) {
    final meta = json['meta'] is Map ? json['meta'] as Map : null;
    final translationName = meta?['translation_name']?.toString() ?? fallbackName ?? '';
    final authorName = meta?['author_name']?.toString() ?? fallbackAuthor ?? '';

    String text = '';
    if (json['translations'] is List && (json['translations'] as List).isNotEmpty) {
      final first = (json['translations'] as List).first;
      if (first is Map) {
        text = first['text']?.toString() ?? '';
      }
    }

    return QuranTranslationModel(
      resourceId: resourceId,
      translationName: translationName,
      authorName: authorName,
      text: text,
      ayahNumber: ayahNumber,
    );
  }
}
