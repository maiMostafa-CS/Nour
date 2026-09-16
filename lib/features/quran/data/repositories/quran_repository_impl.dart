import '../../domain/entities/surah_entity.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_local_data_source.dart';

class QuranRepositoryImpl implements QuranRepository {
  final QuranPagesDataSource dataSource;

  QuranRepositoryImpl(this.dataSource);

  @override
  Future<List<SurahEntity>> getSurahs() {
    return dataSource.getSurahs();
  }

  @override
  Future<PageEntity> getPage(int pageNumber) {
    return dataSource.getPage(pageNumber);
  }
}