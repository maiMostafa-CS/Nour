import '../../data/models/SchedulePrayerNotificationsParams.dart';
import '../repositories/PrayerTimesRepository.dart';


/// Cancels whatever is currently scheduled and schedules a fresh batch.
/// Use this on location change, or to renew the window once the current
/// 30-day batch is close to running out.
class ReschedulePrayerNotifications {
  final PrayerNotificationRepository repository;

  const ReschedulePrayerNotifications(this.repository);

  Future<void> call(SchedulePrayerNotificationsParams params) {
    return repository.rescheduleNotifications(
      latitude: params.latitude,
      longitude: params.longitude,
      days: params.days,
    );
  }
}
