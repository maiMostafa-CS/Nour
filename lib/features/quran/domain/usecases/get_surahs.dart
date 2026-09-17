import '../entities/surah_entity.dart';
import '../repositories/quran_repository.dart';

class GetSurahs {
  final QuranIndexRepository repository;

  const GetSurahs(this.repository);

  Future<List<Surah>> call() async {
    return repository.getSurahs();
  }
}