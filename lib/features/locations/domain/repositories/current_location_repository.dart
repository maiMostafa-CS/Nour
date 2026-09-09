import '../entity/current_location_entity.dart';

abstract class CurrentLocationRepository {
  Future<CurrentLocationEntity> getCurrentLocation();
}