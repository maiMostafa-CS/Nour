import 'package:equatable/equatable.dart';

/// The five daily prayer times for a single calendar day, used as the
/// input for scheduling adhan / reminder / iqama alarms for that day.
class DailyPrayerTimesEntity extends Equatable {
  final DateTime date;
  final DateTime fajr;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const DailyPrayerTimesEntity({
    required this.date,
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  /// Ordered prayers with a stable [PrayerMomentEntity.index] (0..4) that
  /// the data layer uses to build unique, deterministic alarm ids.
  List<PrayerMomentEntity> toMoments() => [
    PrayerMomentEntity(index: 0, name: 'الفجر', time: fajr),
    PrayerMomentEntity(index: 1, name: 'الظهر', time: dhuhr),
    PrayerMomentEntity(index: 2, name: 'العصر', time: asr),
    PrayerMomentEntity(index: 3, name: 'المغرب', time: maghrib),
    PrayerMomentEntity(index: 4, name: 'العشاء', time: isha),
  ];

  @override
  List<Object?> get props => [date, fajr, dhuhr, asr, maghrib, isha];
}

/// A single prayer's name + time, tagged with its fixed order-index.
class PrayerMomentEntity extends Equatable {
  final int index; // 0 = fajr ... 4 = isha, used for id generation
  final String name;
  final DateTime time;

  const PrayerMomentEntity({
    required this.index,
    required this.name,
    required this.time,
  });

  @override
  List<Object?> get props => [index, name, time];
}

/// A full multi-day (e.g. 30-day) schedule request for one location.
class PrayerNotificationScheduleEntity extends Equatable {
  final double latitude;
  final double longitude;
  final List<DailyPrayerTimesEntity> days;

  const PrayerNotificationScheduleEntity({
    required this.latitude,
    required this.longitude,
    required this.days,
  });

  @override
  List<Object?> get props => [latitude, longitude, days];
}