import 'package:equatable/equatable.dart';

/// The six daily prayer moments for a single calendar day,
/// used as the input for scheduling adhan / reminder / iqama alarms.
class DailyPrayerTimesEntity extends Equatable {
  final DateTime date;

  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const DailyPrayerTimesEntity({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  /// Ordered prayer moments:
  ///
  /// 0 = Fajr
  /// 1 = Sunrise
  /// 2 = Dhuhr
  /// 3 = Asr
  /// 4 = Maghrib
  /// 5 = Isha
  ///
  /// These indexes are used to generate unique alarm IDs.
  List<PrayerMomentEntity> toMoments() => [
    PrayerMomentEntity(
      index: 0,
      name: 'الفجر',
      time: fajr,
    ),
    PrayerMomentEntity(
      index: 1,
      name: 'الشروق',
      time: sunrise,
    ),
    PrayerMomentEntity(
      index: 2,
      name: 'الظهر',
      time: dhuhr,
    ),
    PrayerMomentEntity(
      index: 3,
      name: 'العصر',
      time: asr,
    ),
    PrayerMomentEntity(
      index: 4,
      name: 'المغرب',
      time: maghrib,
    ),
    PrayerMomentEntity(
      index: 5,
      name: 'العشاء',
      time: isha,
    ),
  ];

  @override
  List<Object?> get props => [
    date,
    fajr,
    sunrise,
    dhuhr,
    asr,
    maghrib,
    isha,
  ];
}

/// A single prayer moment's name + time,
/// tagged with its fixed order-index.
class PrayerMomentEntity extends Equatable {
  final int index;

  final String name;
  final DateTime time;

  const PrayerMomentEntity({
    required this.index,
    required this.name,
    required this.time,
  });

  @override
  List<Object?> get props => [
    index,
    name,
    time,
  ];
}

/// A full multi-day schedule request for one location.
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
  List<Object?> get props => [
    latitude,
    longitude,
    days,
  ];
}