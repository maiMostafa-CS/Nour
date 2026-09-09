import '../repositories/PrayerTimesRepository.dart';

/// Cancels every alarm previously scheduled by the prayer_notifications
/// feature (adhan, reminder-before-adhan and iqama, across every day).
class CancelPrayerNotifications {
  final PrayerNotificationRepository repository;

  const CancelPrayerNotifications(this.repository);

  Future<void> call() => repository.cancelNotifications();
}