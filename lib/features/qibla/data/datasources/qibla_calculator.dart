import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/config/prayer_scheduler_config.dart';
import '../../domain/entities/qibla_entity.dart';
import '../../qibla_constants.dart';

abstract class QiblaLocalDataSource {
  Future<QiblaEntity> getQiblaDirection();
}

class QiblaLocalDataSourceImpl implements QiblaLocalDataSource {
  static const double kaabaLatitude = QiblaConstants.kaabaLatitude;
  static const double kaabaLongitude = QiblaConstants.kaabaLongitude;

  // Default fallback: Cairo, Egypt
  static const double defaultLatitude = 30.0444;
  static const double defaultLongitude = 31.2357;

  final SharedPreferences? _prefs;

  QiblaLocalDataSourceImpl({SharedPreferences? prefs}) : _prefs = prefs;

  @override
  Future<QiblaEntity> getQiblaDirection() async {
    final locationData = await _getLocationData();

    final qiblaDirection = _calculateQiblaDirection(
      latitude: locationData.latitude,
      longitude: locationData.longitude,
    );

    return QiblaEntity(
      latitude: locationData.latitude,
      longitude: locationData.longitude,
      qiblaDirection: qiblaDirection,
      cityName: locationData.cityName,
    );
  }

  Future<({double latitude, double longitude, String? cityName})>
      _getLocationData() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();

    // 1️⃣ Priority: Read saved/cached location from SharedPreferences (100% offline, no GPS required)
    final savedLat = prefs.getDouble('prayer_manual_latitude') ??
        prefs.getDouble(prayerLastLatitudePrefsKey) ??
        prefs.getDouble(prayerScheduledLatitudePrefsKey);
    final savedLng = prefs.getDouble('prayer_manual_longitude') ??
        prefs.getDouble(prayerLastLongitudePrefsKey) ??
        prefs.getDouble(prayerScheduledLongitudePrefsKey);
    final savedCity = prefs.getString('prayer_city_name');

    if (savedLat != null && savedLng != null) {
      debugPrint(
        '🕋 Qibla: Using saved location ($savedLat, $savedLng) | city: $savedCity',
      );
      return (
        latitude: savedLat,
        longitude: savedLng,
        cityName: savedCity,
      );
    }

    // 2️⃣ Optional: Silently check last known position (if location permission was previously granted)
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          debugPrint(
            '🕋 Qibla: Using last known GPS position (${lastKnown.latitude}, ${lastKnown.longitude})',
          );
          return (
            latitude: lastKnown.latitude,
            longitude: lastKnown.longitude,
            cityName: savedCity,
          );
        }
      }
    } catch (e) {
      debugPrint('🕋 Qibla: getLastKnownPosition silent failure: $e');
    }

    // 3️⃣ Optional: If GPS is active and permission already granted, attempt a quick fetch (non-blocking)
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 2),
            ),
          );
          debugPrint(
            '🕋 Qibla: Using live GPS position (${position.latitude}, ${position.longitude})',
          );
          return (
            latitude: position.latitude,
            longitude: position.longitude,
            cityName: savedCity,
          );
        }
      }
    } catch (e) {
      debugPrint('🕋 Qibla: getCurrentPosition silent failure: $e');
    }

    // 4️⃣ Default fallback (Cairo) so Qibla NEVER throws or blocks offline
    debugPrint('🕋 Qibla: Fallback to default Cairo coordinates');
    return (
      latitude: defaultLatitude,
      longitude: defaultLongitude,
      cityName: savedCity ?? 'القاهرة',
    );
  }

  double _calculateQiblaDirection({
    required double latitude,
    required double longitude,
  }) {
    final userLatitude = _toRadians(latitude);
    final kaabaLat = _toRadians(kaabaLatitude);
    final deltaLongitude = _toRadians(kaabaLongitude - longitude);

    final y = sin(deltaLongitude);
    final x = cos(userLatitude) * tan(kaabaLat) -
        sin(userLatitude) * cos(deltaLongitude);

    final bearing = atan2(y, x);

    return _normalizeDegrees(
      _toDegrees(bearing),
    );
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  double _toDegrees(double radians) {
    return radians * 180 / pi;
  }

  double _normalizeDegrees(double degrees) {
    return (degrees + 360) % 360;
  }
}