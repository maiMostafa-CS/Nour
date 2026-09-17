import '../../domain/entities/surah_entity.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_local_data_source.dart';

class QuranIndexRepositoryImpl implements QuranIndexRepository {
  final QuranIndexLocalDataSource localDataSource;

  const QuranIndexRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<List<Surah>> getSurahs() async {
    return localDataSource.getSurahs();
  }
}