import 'dart:math';

import 'package:geolocator/geolocator.dart';

import '../../domain/entities/qibla_entity.dart';

abstract class QiblaLocalDataSource {
  Future<QiblaEntity> getQiblaDirection();
}

class QiblaLocalDataSourceImpl
    implements QiblaLocalDataSource {
  static const double kaabaLatitude = 21.422487;
  static const double kaabaLongitude = 39.826206;

  @override
  Future<QiblaEntity> getQiblaDirection() async {
    final position = await _getCurrentPosition();

    final qiblaDirection = _calculateQiblaDirection(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    return QiblaEntity(
      latitude: position.latitude,
      longitude: position.longitude,
      qiblaDirection: qiblaDirection,
    );
  }

  Future<Position> _getCurrentPosition() async {
    final serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'يرجى تشغيل خدمة الموقع GPS',
      );
    }

    var permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
      await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception(
        'تم رفض صلاحية الموقع',
      );
    }

    if (permission ==
        LocationPermission.deniedForever) {
      throw Exception(
        'صلاحية الموقع مرفوضة نهائيًا، '
            'يرجى تفعيلها من إعدادات التطبيق',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  double _calculateQiblaDirection({
    required double latitude,
    required double longitude,
  }) {
    final userLatitude = _toRadians(latitude);

    final kaabaLat =
    _toRadians(kaabaLatitude);

    final deltaLongitude = _toRadians(
      kaabaLongitude - longitude,
    );

    final y = sin(deltaLongitude);

    final x =
        cos(userLatitude) * tan(kaabaLat) -
            sin(userLatitude) *
                cos(deltaLongitude);

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