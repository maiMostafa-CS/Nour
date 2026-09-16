import '../entities/surah_entity.dart';
import '../repositories/quran_repository.dart';

class GetSurahs {
  final QuranRepository repository;

  GetSurahs(this.repository);

  Future<List<SurahEntity>> call() {
    return repository.getSurahs();
  }
}