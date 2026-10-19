import '../../domain/entities/quran_translation.dart';
import '../../domain/entities/quran_translation_resource.dart';
import '../../domain/repositories/quran_translation_repository.dart';
import '../datasources/quran_translation_remote_data_source.dart';

class QuranTranslationRepositoryImpl implements QuranTranslationRepository {
  final QuranTranslationRemoteDataSource remoteDataSource;

  QuranTranslationRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<QuranTranslationResource>> getTranslationResources({
    String language = 'english',
  }) {
    return remoteDataSource.getTranslationResources(
      language: language,
    );
  }

  @override
  Future<QuranTranslation?> getAyahTranslation({
    required int surahNumber,
    required int ayahNumber,
    required int resourceId,
  }) {
    return remoteDataSource.getAyahTranslation(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      resourceId: resourceId,
    );
  }

  @override
  Future<List<QuranTranslation>> getChapterTranslation({
    required int chapterNumber,
    required int resourceId,
  }) {
    return remoteDataSource.getChapterTranslation(
      chapterNumber: chapterNumber,
      resourceId: resourceId,
    );
  }
}
