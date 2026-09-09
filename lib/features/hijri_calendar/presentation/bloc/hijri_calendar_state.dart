import 'package:equatable/equatable.dart';

import '../../domain/entities/hijri_date_entity.dart';
import '../../../prayer_times/domain/entities/prayer_times_entity.dart';

abstract class HijriCalendarState extends Equatable {
  const HijriCalendarState();

  @override
  List<Object?> get props => [];
}

class HijriCalendarInitial extends HijriCalendarState {
  const HijriCalendarInitial();
}

class HijriCalendarLoading extends HijriCalendarState {
  const HijriCalendarLoading();
}

class HijriCalendarLoaded extends HijriCalendarState {
  final List<HijriDateEntity> dates;

  final int year;
  final int month;

  final HijriDateEntity? selectedDate;

  final PrayerTimesEntity? prayerTimes;

  const HijriCalendarLoaded({
    required this.dates,
    required this.year,
    required this.month,
    this.selectedDate,
    this.prayerTimes,
  });

  HijriCalendarLoaded copyWith({
    List<HijriDateEntity>? dates,
    int? year,
    int? month,
    HijriDateEntity? selectedDate,
    PrayerTimesEntity? prayerTimes,
  }) {
    return HijriCalendarLoaded(
      dates: dates ?? this.dates,
      year: year ?? this.year,
      month: month ?? this.month,
      selectedDate: selectedDate ?? this.selectedDate,
      prayerTimes: prayerTimes ?? this.prayerTimes,
    );
  }

  @override
  List<Object?> get props => [
    dates,
    year,
    month,
    selectedDate,
    prayerTimes,
  ];
}

class HijriCalendarError extends HijriCalendarState {
  final String message;

  const HijriCalendarError(this.message);

  @override
  List<Object?> get props => [message];
}