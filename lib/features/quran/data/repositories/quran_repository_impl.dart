import '../../domain/entities/surah_entity.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_local_data_source.dart';

class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDataSource dataSource;
  QuranRepositoryImpl(this.dataSource);

  @override
  Future<List<SurahEntity>> getSurahs() => dataSource.getSurahs();
}
