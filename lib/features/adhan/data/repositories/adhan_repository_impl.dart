import '../../domain/entities/adhan_reciter_entity.dart';
import '../../domain/repositories/adhan_repository.dart';
import '../datasources/adhan_local_data_source.dart';

class AdhanRepositoryImpl implements AdhanRepository {
  final AdhanLocalDataSource localDataSource;

  const AdhanRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<List<AdhanReciterEntity>> getReciters() {
    return localDataSource.getReciters();
  }

  @override
  Future<String?> getSelectedReciterId() {
    return localDataSource.getSelectedReciterId();
  }

  @override
  Future<void> saveSelectedReciter(
      String reciterId,
      ) {
    return localDataSource.saveSelectedReciter(
      reciterId,
    );
  }
}