import '../entities/surah_entity.dart';
import '../repositories/quran_repository.dart';

class GetPage {
  final QuranRepository repository;

  GetPage(this.repository);

  Future<PageEntity> call(int pageNumber) {
    return repository.getPage(pageNumber);
  }
}