import '../../domain/entity/location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_local_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationLocalDataSource localDataSource;

  LocationRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<List<LocationEntity>> getLocations() async {
    return localDataSource.getLocations();
  }

  @override
  Future<List<LocationEntity>> getCountries() async {
    final locations = await localDataSource.getLocations();

    return locations;
  }

  @override
  Future<List<LocationEntity>> getCitiesByCountry(
      String countryCode,
      ) async {
    final locations = await localDataSource.getLocations();

    return locations
        .where(
          (location) =>
      location.countryCode.toUpperCase() ==
          countryCode.toUpperCase(),
    )
        .toList();
  }

  @override
  Future<LocationEntity?> getLocationByCity(
      String city,
      ) async {
    final locations = await localDataSource.getLocations();

    try {
      return locations.firstWhere(
            (location) =>
        location.city.toLowerCase() ==
            city.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}