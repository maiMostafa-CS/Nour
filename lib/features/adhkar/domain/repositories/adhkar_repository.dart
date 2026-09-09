import '../entities/dhikr_entity.dart';

abstract class AdhkarRepository {
  Future<List<DhikrEntity>> getAdhkar();
}
