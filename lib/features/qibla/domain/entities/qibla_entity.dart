class QiblaEntity {
  final double latitude;
  final double longitude;
  final double qiblaDirection;
  final String? cityName;

  const QiblaEntity({
    required this.latitude,
    required this.longitude,
    required this.qiblaDirection,
    this.cityName,
  });
}