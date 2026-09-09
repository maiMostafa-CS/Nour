import '../entities/prayer_times_entity.dart';

abstract class PrayerRepository {
  Future<PrayerTimesEntity> getPrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
  });
}