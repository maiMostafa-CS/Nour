import '../entities/quran_translation.dart';
import '../repositories/quran_translation_repository.dart';

class GetChapterTranslation {
  final QuranTranslationRepository repository;

  GetChapterTranslation(this.repository);

  Future<List<QuranTranslation>> call({
    required int chapterNumber,
    required int resourceId,
  }) {
    return repository.getChapterTranslation(
      chapterNumber: chapterNumber,
      resourceId: resourceId,
    );
  }
}
