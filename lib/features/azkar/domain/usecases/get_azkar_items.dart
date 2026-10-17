import '../repositories/azkar_repository.dart';

class GetAzkarItems {
  final AzkarRepository repository;

  GetAzkarItems(this.repository);

  List<dynamic> call(int chapterId, [String langCode = 'ar']) {
    return repository.getItemsByChapter(chapterId, langCode);
  }
}
