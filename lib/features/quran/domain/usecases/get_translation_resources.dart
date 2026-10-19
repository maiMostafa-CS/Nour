import '../entities/quran_translation_resource.dart';
import '../repositories/quran_translation_repository.dart';

class GetTranslationResources {
  final QuranTranslationRepository repository;

  GetTranslationResources(this.repository);

  Future<List<QuranTranslationResource>> call({
    String language = 'english',
  }) {
    return repository.getTranslationResources(
      language: language,
    );
  }
}
