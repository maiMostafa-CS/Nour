import 'package:equatable/equatable.dart';

import '../../domain/repositories/PrayerTimesRepository.dart';

class SchedulePrayerNotificationsParams extends Equatable {
  final double latitude;
  final double longitude;
  final int days;

  const SchedulePrayerNotificationsParams({
    required this.latitude,
    required this.longitude,
    this.days = 30,
  });

  @override
  List<Object?> get props => [latitude, longitude, days];
}

/// Schedules adhan/reminder/iqama alarms for [days] days ahead in one go.
class SchedulePrayerNotifications {
  final PrayerNotificationRepository repository;

  const SchedulePrayerNotifications(this.repository);

  Future<void> call(SchedulePrayerNotificationsParams params) {
    return repository.scheduleNotifications(
      latitude: params.latitude,
      longitude: params.longitude,
      days: params.days,
    );
  }
}