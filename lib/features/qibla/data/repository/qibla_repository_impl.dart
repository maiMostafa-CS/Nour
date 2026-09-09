import '../../domain/entities/qibla_entity.dart';
import '../../domain/repositories/qibla_repository.dart';
import '../datasources/qibla_calculator.dart';

class QiblaRepositoryImpl
    implements QiblaRepository {
  final QiblaLocalDataSource localDataSource;

  QiblaRepositoryImpl(
      this.localDataSource,
      );

  @override
  Future<QiblaEntity> getQiblaDirection() {
    return localDataSource.getQiblaDirection();
  }
}