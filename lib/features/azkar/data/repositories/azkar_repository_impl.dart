import '../../domain/repositories/azkar_repository.dart';
import '../datasources/azkar_local_data_source.dart';

class AzkarRepositoryImpl implements AzkarRepository {
  final AzkarLocalDataSource localDataSource;

  AzkarRepositoryImpl(this.localDataSource);

  @override
  List<dynamic> getCategories([String langCode = 'ar']) {
    return localDataSource.getCategories(langCode);
  }

  @override
  List<dynamic> getChaptersByCategory(int categoryId, [String langCode = 'ar']) {
    return localDataSource.getChaptersByCategory(categoryId, langCode);
  }

  @override
  List<dynamic> getItemsByChapter(int chapterId, [String langCode = 'ar']) {
    return localDataSource.getItemsByChapter(chapterId, langCode);
  }
}
