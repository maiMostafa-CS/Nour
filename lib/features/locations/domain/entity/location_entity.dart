class LocationEntity {
  final String country;
  final String countryEn;
  final String countryCode;
  final String city;
  final String cityEn;
  final double latitude;
  final double longitude;
  final String coordinateType;
  final String timezone;

  const LocationEntity({
    required this.country,
    this.countryEn = '',
    required this.countryCode,
    required this.city,
    this.cityEn = '',
    required this.latitude,
    required this.longitude,
    required this.coordinateType,
    required this.timezone,
  });

  String getLocalizedCountry(String languageCode) {
    if (languageCode == 'en' && countryEn.isNotEmpty) {
      return countryEn;
    }
    return country;
  }

  String getLocalizedCity(String languageCode) {
    if (languageCode == 'en' && cityEn.isNotEmpty) {
      return cityEn;
    }
    return city;
  }
}
