import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

abstract class CurrentLocationDataSource {
  Future<Position> getCurrentLocation();
}

class CurrentLocationDataSourceImpl implements CurrentLocationDataSource {
  @override
  Future<Position> getCurrentLocation() async {
    try {
      // ═══════════════════════════════════════════════════════
      // 1. التحقق من الـ service
      // ═══════════════════════════════════════════════════════
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location service is disabled');
      }
      debugPrint('📍 Location service enabled ✅');

      // ═══════════════════════════════════════════════════════
      // 2. التحقق من الصلاحيات
      // ═══════════════════════════════════════════════════════
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('📍 Permission: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('📍 Permission after request: $permission');
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied: $permission');
      }

      // ═══════════════════════════════════════════════════════
      // 3. جرّب آخر موقع معروف (سريع جداً)
      // ═══════════════════════════════════════════════════════
      debugPrint('📍 Trying last known position...');
      Position? position = await Geolocator.getLastKnownPosition();

      if (position != null) {
        debugPrint(
          '✅ Last known position: '
              'lat=${position.latitude}, lng=${position.longitude}',
        );
        return position;
      }

      debugPrint('⚠️ No last known position → using stream');

      // ═══════════════════════════════════════════════════════
      // 4. استخدم Stream بدل getCurrentPosition (أكثر استقرار)
      // ═══════════════════════════════════════════════════════
      debugPrint('📍 GETTING CURRENT GPS LOCATION via stream...');

      final positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 0,
        ),
      );

      position = await positionStream.first.timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          debugPrint('⏰ Stream timeout after 20s');
          throw TimeoutException('Location stream timeout', const Duration(seconds: 20));
        },
      );

      debugPrint(
        '✅ CURRENT GPS LOCATION | '
            'lat=${position.latitude} | '
            'lng=${position.longitude}',
      );

      return position;
    } catch (e, stackTrace) {
      debugPrint('❌ CURRENT LOCATION ERROR: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }
}