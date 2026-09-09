import '../entities/qibla_entity.dart';
import '../repositories/qibla_repository.dart';

class GetQiblaDirection {
  final QiblaRepository repository;

  GetQiblaDirection(this.repository);

  Future<QiblaEntity> call() {
    return repository.getQiblaDirection();
  }
}