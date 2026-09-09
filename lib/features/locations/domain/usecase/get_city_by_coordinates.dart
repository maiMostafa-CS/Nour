import '../entity/location_entity.dart';
import '../repositories/location_repository.dart';

class GetLocationByCity {
  final LocationRepository repository;

  GetLocationByCity(this.repository);

  Future<LocationEntity?> call(
      String city,
      ) {
    return repository.getLocationByCity(
      city,
    );
  }
}