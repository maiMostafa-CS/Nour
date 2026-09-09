import '../entities/qibla_entity.dart';

abstract class QiblaRepository {
  Future<QiblaEntity> getQiblaDirection();
}