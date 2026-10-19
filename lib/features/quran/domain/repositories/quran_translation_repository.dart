import '../entities/quran_translation.dart';
import '../entities/quran_translation_resource.dart';

abstract class QuranTranslationRepository {
  Future<List<QuranTranslationResource>> getTranslationResources({
    String language = 'english',
  });

  Future<QuranTranslation?> getAyahTranslation({
    required int surahNumber,
    required int ayahNumber,
    required int resourceId,
  });

  Future<List<QuranTranslation>> getChapterTranslation({
    required int chapterNumber,
    required int resourceId,
  });
}
