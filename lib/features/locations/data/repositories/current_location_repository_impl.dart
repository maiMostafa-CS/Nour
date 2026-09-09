// import 'package:flutter/cupertino.dart';
//
// import '../../domain/entity/current_location_entity.dart';
// import '../../domain/repositories/current_location_repository.dart';
// import '../datasources/current_location_data_source.dart';
//
// class CurrentLocationRepositoryImpl
//     implements CurrentLocationRepository {
//   final CurrentLocationDataSource dataSource;
//
//   CurrentLocationRepositoryImpl({
//     required this.dataSource,
//   });
//
//   @override
//   Future<CurrentLocationEntity>
//   getCurrentLocation() async {
//     final position =
//     await dataSource.getCurrentLocation();
//
//     return CurrentLocationEntity(
//       latitude: position.latitude,
//       longitude: position.longitude,
//       city: position.city
//     );
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

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
    // ============================================================
    // 1. GET GPS POSITION
    // ============================================================

    final position =
    await dataSource.getCurrentLocation();

    debugPrint(
      '📍 GPS POSITION | '
          'lat=${position.latitude} | '
          'lng=${position.longitude}',
    );

    // ============================================================
    // 2. REVERSE GEOCODING
    // coordinates -> city + country
    // ============================================================

    String city = '';
    String country = '';

    try {
      final List<Placemark> placemarks =
      await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark placemark =
            placemarks.first;

        city =
            placemark.locality ??
                placemark.subAdministrativeArea ??
                placemark.administrativeArea ??
                '';

        country =
            placemark.country ?? '';

        debugPrint(
          '🌍 REVERSE GEOCODING | '
              'city=$city | '
              'country=$country',
        );
      }
    } catch (e) {
      debugPrint(
        '❌ REVERSE GEOCODING ERROR | $e',
      );
    }

    // ============================================================
    // 3. RETURN DOMAIN ENTITY
    // ============================================================

    return CurrentLocationEntity(
      latitude: position.latitude,
      longitude: position.longitude,
      city: city,
      country: country,
    );
  }
}