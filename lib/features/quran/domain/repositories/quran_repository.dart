
import '../entities/surah_entity.dart';

abstract class QuranIndexRepository {
  Future<List<Surah>> getSurahs();
}