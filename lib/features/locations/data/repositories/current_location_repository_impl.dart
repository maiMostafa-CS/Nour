import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geocoding/geocoding.dart';

import '../../domain/entity/current_location_entity.dart';
import '../../domain/repositories/current_location_repository.dart';
import '../datasources/current_location_data_source.dart';

class CurrentLocationRepositoryImpl
    implements CurrentLocationRepository {
  final CurrentLocationDataSource dataSource;

  final Geocoding _geocoding = Geocoding();

  CurrentLocationRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<CurrentLocationEntity> getCurrentLocation() async {
    final position = await dataSource.getCurrentLocation();

    debugPrint(
      '📍 GPS POSITION | '
      'lat=${position.latitude} | '
      'lng=${position.longitude}',
    );

    String city = '';
    String country = '';

    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;

        city = placemark.locality ??
            placemark.subAdministrativeArea ??
            placemark.administrativeArea ??
            '';

        country = placemark.country ?? '';

        debugPrint(
          '🌍 REVERSE GEOCODING | '
          'city=$city | country=$country',
        );
      }
    } catch (e) {
      debugPrint('❌ REVERSE GEOCODING ERROR | $e');
    }

    // Current GPS location normally uses the timezone configured on
    // the device. Manual locations use the timezone stored with the city.
    String timezone = '';

    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      timezone = timezoneInfo.identifier;

      debugPrint('🕐 CURRENT LOCATION TIMEZONE = $timezone');
    } catch (e) {
      debugPrint('❌ TIMEZONE LOOKUP ERROR | $e');
    }

    return CurrentLocationEntity(
      latitude: position.latitude,
      longitude: position.longitude,
      city: city,
      country: country,
      timezone: timezone,
    );
  }
}
