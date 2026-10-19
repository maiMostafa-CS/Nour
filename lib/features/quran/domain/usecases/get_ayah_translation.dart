import '../entities/quran_translation.dart';
import '../repositories/quran_translation_repository.dart';

class GetAyahTranslation {
  final QuranTranslationRepository repository;

  GetAyahTranslation(this.repository);

  Future<QuranTranslation?> call({
    required int surahNumber,
    required int ayahNumber,
    required int resourceId,
  }) {
    return repository.getAyahTranslation(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      resourceId: resourceId,
    );
  }
}
