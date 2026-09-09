import '../entity/location_entity.dart';

abstract class LocationRepository {
  Future<List<LocationEntity>> getLocations();

  Future<List<LocationEntity>> getCountries();

  Future<List<LocationEntity>> getCitiesByCountry(
      String countryCode,
      );

  Future<LocationEntity?> getLocationByCity(
      String city,
      );
}