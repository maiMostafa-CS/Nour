import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/data/datasources/prayer_notification_local_data_source.dart';
import '../../domain/repositories/PrayerTimesRepository.dart';


class PrayerNotificationRepositoryImpl
    implements PrayerNotificationRepository {
  PrayerNotificationRepositoryImpl({
    required PrayerNotificationLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final PrayerNotificationLocalDataSource _localDataSource;


  static const int _windowDays = 2;

  @override
  Future<void> scheduleNotifications({
    required double latitude,
    required double longitude,
    int days = _windowDays,
  }) {
    // First time (or after a location change): ensure the window is scheduled from scratch.
    return _localDataSource.ensureWindowScheduled(
      latitude: latitude,
      longitude: longitude,
      days: days,
    );
  }

  @override
  Future<void> cancelNotifications() => _localDataSource.cancelAll();

  @override
  Future<void> rescheduleNotifications({
    required double latitude,
    required double longitude,
    int days = _windowDays,
  }) async {
    // Full reschedule (for example, after a location change): clear everything old
    // first so nothing remains scheduled with incorrect coordinates, then rebuild the window
    // again using the new coordinates.
    await _localDataSource.cancelAll();
    return _localDataSource.ensureWindowScheduled(
      latitude: latitude,
      longitude: longitude,
      days: days,
    );
  }

  @override
  Future<void> onAlarmFired({
    required double latitude,
    required double longitude,
    int days = _windowDays,
  }) {
    // Called by the Alarm.ringing listener in main.dart whenever an adhan/reminder/
    // iqama rings. It automatically extends the window by one day (auto-renew) without
    // clearing anything, unlike reschedule which clears and rebuilds from scratch.
    return _localDataSource.onAlarmFired(
      latitude: latitude,
      longitude: longitude,
      days: days,
    );
  }
}