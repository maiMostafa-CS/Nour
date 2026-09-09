import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class LoadLocations extends LocationEvent {
  const LoadLocations();
}

class LoadCitiesByCountry extends LocationEvent {
  final String countryCode;

  const LoadCitiesByCountry(
      this.countryCode,
      );

  @override
  List<Object?> get props => [countryCode];
}

class FindLocationByCity extends LocationEvent {
  final String city;

  const FindLocationByCity(
      this.city,
      );

  @override
  List<Object?> get props => [city];
}
class GetCurrentLocation extends LocationEvent {
  const GetCurrentLocation();
}