import '../../domain/entity/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({
    required super.country,
    required super.countryCode,
    required super.city,
    required super.latitude,
    required super.longitude,
    required super.coordinateType,
    required super.timezone,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      country: json['country'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
      city: json['city'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      coordinateType: json['coordinateType'] as String? ?? '',
      timezone: (json['timezone'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'countryCode': countryCode,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'coordinateType': coordinateType,
      'timezone': timezone,
    };
  }
}
