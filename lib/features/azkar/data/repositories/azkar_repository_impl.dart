import '../../domain/repositories/azkar_repository.dart';
import '../datasources/azkar_local_data_source.dart';

class AzkarRepositoryImpl implements AzkarRepository {
  final AzkarLocalDataSource localDataSource;

  AzkarRepositoryImpl(this.localDataSource);

  @override
  List<dynamic> getCategories() {
    return localDataSource.getCategories();
  }

  @override
  List<dynamic> getChaptersByCategory(int categoryId) {
    return localDataSource.getChaptersByCategory(categoryId);
  }

  @override
  List<dynamic> getItemsByChapter(int chapterId) {
    return localDataSource.getItemsByChapter(chapterId);
  }
}
