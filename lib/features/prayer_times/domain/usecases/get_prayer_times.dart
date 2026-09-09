import '../entities/prayer_times_entity.dart';
import '../repositories/prayer_repository.dart';

class GetPrayerTimes {
  final PrayerRepository repository;

  GetPrayerTimes(this.repository);

  Future<PrayerTimesEntity> call({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) {
    return repository.getPrayerTimes(
      latitude: latitude,
      longitude: longitude,
      date: date,
    );
  }
}