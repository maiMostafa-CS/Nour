part of 'prayer_bloc.dart';

abstract class PrayerState extends Equatable {
  const PrayerState();

  @override
  List<Object?> get props => [];
}

class PrayerInitial extends PrayerState {
  const PrayerInitial();
}

class PrayerLoading extends PrayerState {
  const PrayerLoading();
}

class PrayerLoaded extends PrayerState {
  final PrayerTimesEntity prayerTimes;

  const PrayerLoaded(this.prayerTimes);

  @override
  List<Object?> get props => [
    prayerTimes,
  ];
}

class PrayerError extends PrayerState {
  final String message;

  const PrayerError(this.message);

  @override
  List<Object?> get props => [
    message,
  ];
}

enum PrayerNotificationStatus {
  initial,
  loading,
  scheduled,
  cancelled,
  failure,
}

class PrayerNotificationState extends Equatable {
  final PrayerNotificationStatus status;
  final int scheduledDays;
  final String? errorMessage;

  const PrayerNotificationState({
    this.status = PrayerNotificationStatus.initial,
    this.scheduledDays = 0,
    this.errorMessage,
  });

  PrayerNotificationState copyWith({
    PrayerNotificationStatus? status,
    int? scheduledDays,
    String? errorMessage,
  }) {
    return PrayerNotificationState(
      status: status ?? this.status,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, scheduledDays, errorMessage];
}