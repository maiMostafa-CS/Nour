import 'package:equatable/equatable.dart';

class CurrentLocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String city;
  final String country;
  final String timezone;

  const CurrentLocationEntity({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    required this.timezone,
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        city,
        country,
        timezone,
      ];
}
