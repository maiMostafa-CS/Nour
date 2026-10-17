import '../repositories/azkar_repository.dart';

class GetAzkarChapters {
  final AzkarRepository repository;

  GetAzkarChapters(this.repository);

  List<dynamic> call(int categoryId, [String langCode = 'ar']) {
    return repository.getChaptersByCategory(categoryId, langCode);
  }
}
