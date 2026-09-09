import '../entity/location_entity.dart';
import '../repositories/location_repository.dart';

class GetAllLocations {
  final LocationRepository repository;

  GetAllLocations(this.repository);

  Future<List<LocationEntity>> call() {
    return repository.getLocations();
  }
}