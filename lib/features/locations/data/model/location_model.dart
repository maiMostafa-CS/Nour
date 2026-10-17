import '../../domain/entity/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({
    required super.country,
    super.countryEn = '',
    required super.countryCode,
    required super.city,
    super.cityEn = '',
    required super.latitude,
    required super.longitude,
    required super.coordinateType,
    required super.timezone,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      country: json['country'] as String? ?? '',
      countryEn: json['countryEn'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
      city: json['city'] as String? ?? '',
      cityEn: json['cityEn'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      coordinateType: json['coordinateType'] as String? ?? '',
      timezone: (json['timezone'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'countryEn': countryEn,
      'countryCode': countryCode,
      'city': city,
      'cityEn': cityEn,
      'latitude': latitude,
      'longitude': longitude,
      'coordinateType': coordinateType,
      'timezone': timezone,
    };
  }
}
