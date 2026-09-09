import '../entity/location_entity.dart';
import '../repositories/location_repository.dart';

class GetCitiesByCountry {
  final LocationRepository repository;

  GetCitiesByCountry(this.repository);

  Future<List<LocationEntity>> call(
      String countryCode,
      ) {
    return repository.getCitiesByCountry(
      countryCode,
    );
  }
}