import '../entity/location_entity.dart';
import '../repositories/location_repository.dart';

class GetCountries {
  final LocationRepository repository;

  GetCountries(this.repository);

  Future<List<LocationEntity>> call() {
    return repository.getCountries();
  }
}