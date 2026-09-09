part of 'prayer_bloc.dart';

abstract class PrayerEvent extends Equatable {
  const PrayerEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrayerTimes extends PrayerEvent {
  final double latitude;
  final double longitude;
  final DateTime date;

  const LoadPrayerTimes({
    required this.latitude,
    required this.longitude,
    required this.date,
  });

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    date,
  ];
}

abstract class PrayerNotificationEvent extends Equatable {
  const PrayerNotificationEvent();

  @override
  List<Object?> get props => [];
}

class ScheduleNotificationsRequested extends PrayerNotificationEvent {
  final double latitude;
  final double longitude;
  final int days;

  const ScheduleNotificationsRequested({
    required this.latitude,
    required this.longitude,
    this.days = 30,
  });

  @override
  List<Object?> get props => [latitude, longitude, days];
}

class RescheduleNotificationsRequested extends PrayerNotificationEvent {
  final double latitude;
  final double longitude;
  final int days;

  const RescheduleNotificationsRequested({
    required this.latitude,
    required this.longitude,
    this.days = 30,
  });

  @override
  List<Object?> get props => [latitude, longitude, days];
}

class CancelNotificationsRequested extends PrayerNotificationEvent {
  const CancelNotificationsRequested();
}