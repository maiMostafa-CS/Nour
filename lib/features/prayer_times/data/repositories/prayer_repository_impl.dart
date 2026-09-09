import '../../domain/entities/prayer_times_entity.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../datasources/prayer_local_data_source.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final PrayerLocalDataSource localDataSource;

  PrayerRepositoryImpl(this.localDataSource);

  @override
  Future<PrayerTimesEntity> getPrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    return localDataSource.calculate(
      latitude: latitude,
      longitude: longitude,
      date: date,
    );
  }
}