import '../../domain/entities/quran_translation_resource.dart';

class QuranTranslationResourceModel extends QuranTranslationResource {
  const QuranTranslationResourceModel({
    required super.id,
    required super.name,
    required super.authorName,
    required super.languageName,
  });

  factory QuranTranslationResourceModel.fromJson(Map<String, dynamic> json) {
    return QuranTranslationResourceModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? '',
      languageName: json['language_name']?.toString() ?? 'english',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'author_name': authorName,
      'language_name': languageName,
    };
  }
}
