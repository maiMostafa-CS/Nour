import '../entities/dhikr_entity.dart';
import '../repositories/adhkar_repository.dart';

class GetAdhkar {
  final AdhkarRepository repository;
  GetAdhkar(this.repository);
  Future<List<DhikrEntity>> call() => repository.getAdhkar();
}
