import '../entities/adhan_reciter_entity.dart';
import '../repositories/adhan_repository.dart';

class GetAdhans {
  final AdhanRepository repository;

  const GetAdhans(this.repository);

  Future<List<AdhanReciterEntity>> call() {
    return repository.getReciters();
  }
}