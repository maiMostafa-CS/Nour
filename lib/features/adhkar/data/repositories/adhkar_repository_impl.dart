import '../../domain/entities/dhikr_entity.dart';
import '../../domain/repositories/adhkar_repository.dart';
import '../datasources/adhkar_local_data_source.dart';

class AdhkarRepositoryImpl implements AdhkarRepository {
  final AdhkarLocalDataSource dataSource;
  AdhkarRepositoryImpl(this.dataSource);

  @override
  Future<List<DhikrEntity>> getAdhkar() => dataSource.getAdhkar();
}
