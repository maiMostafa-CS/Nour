import 'package:equatable/equatable.dart';

import '../../domain/entity/location_entity.dart';
import '../../domain/entity/current_location_entity.dart';

enum LocationStatus {
  initial,
  loading,
  success,
  failure,
}

class LocationState extends Equatable {
  final LocationStatus status;

  // List of countries/cities
  final List<LocationEntity> locations;

  // Manually selected city
  final LocationEntity? selectedLocation;

  // Device GPS location
  final CurrentLocationEntity? currentLocation;

  final String? errorMessage;

  const LocationState({
    this.status = LocationStatus.initial,
    this.locations = const [],
    this.selectedLocation,
    this.currentLocation,
    this.errorMessage,
  });

  LocationState copyWith({
    LocationStatus? status,
    List<LocationEntity>? locations,
    LocationEntity? selectedLocation,
    CurrentLocationEntity? currentLocation,
    String? errorMessage,
  }) {
    return LocationState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      currentLocation: currentLocation ?? this.currentLocation,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    locations,
    selectedLocation,
    currentLocation,
    errorMessage,
  ];
}