import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

import '../../domain/entity/current_location_entity.dart';
import '../../domain/repositories/current_location_repository.dart';
import '../datasources/current_location_data_source.dart';

class CurrentLocationRepositoryImpl implements CurrentLocationRepository {
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

    // ═══════════════════════════════════════════════════════
    // 1️⃣ جرّب Geocoder الأول (لو شغال)
    // ═══════════════════════════════════════════════════════
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        locale: const Locale('ar'),
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        city = placemark.locality ??
            placemark.subAdministrativeArea ??
            placemark.administrativeArea ??
            '';
        country = placemark.country ?? '';

        debugPrint('✅ Geocoder SUCCESS: $city, $country');
      }
    } catch (e) {
      debugPrint('⚠️ Geocoder FAILED | $e');
      debugPrint('🔄 Falling back to Nominatim...');

      // ═══════════════════════════════════════════════════════
      // 2️⃣ Fallback: استخدم Nominatim (OpenStreetMap)
      // ═══════════════════════════════════════════════════════
      try {
        final result = await _getCityFromNominatim(
          position.latitude,
          position.longitude,
        );

        city = result['city'] ?? '';
        country = result['country'] ?? '';

        debugPrint('✅ Nominatim SUCCESS: $city, $country');
      } catch (e2) {
        debugPrint('❌ Nominatim FAILED too | $e2');
      }
    }

    // ═══════════════════════════════════════════════════════
    // 3️⃣ الـ timezone
    // ═══════════════════════════════════════════════════════
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

  // ═══════════════════════════════════════════════════════════
  // Nominatim API (OpenStreetMap) — مجاني
  // ═══════════════════════════════════════════════════════════
  Future<Map<String, String>> _getCityFromNominatim(
      double lat,
      double lng,
      ) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
          '?format=json'
          '&lat=$lat'
          '&lon=$lng'
          '&accept-language=ar'
          '&zoom=10',
    );

    debugPrint('🌐 Nominatim URL: $url');

    final response = await http.get(
      url,
      headers: {
        // ⚠️ مهم جداً: Nominatim محتاج User-Agent
        'User-Agent': 'IslamicApp/1.0 (contact@example.com)',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Nominatim HTTP ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final address = data['address'] as Map<String, dynamic>? ?? {};

    // أولوية المدينة: city → town → village → state
    final city = address['city'] ??
        address['town'] ??
        address['village'] ??
        address['state'] ??
        '';

    final country = address['country'] ?? '';

    return {
      'city': city.toString(),
      'country': country.toString(),
    };
  }
}