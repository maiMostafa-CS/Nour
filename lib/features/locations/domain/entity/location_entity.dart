class LocationEntity {
  final String country;
  final String countryCode;
  final String city;
  final double latitude;
  final double longitude;
  final String coordinateType;

  const LocationEntity({
    required this.country,
    required this.countryCode,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.coordinateType,
  });
}