import 'package:equatable/equatable.dart';

abstract class HijriCalendarEvent extends Equatable {
  const HijriCalendarEvent();

  @override
  List<Object?> get props => [];
}

class LoadHijriCalendar extends HijriCalendarEvent {
  const LoadHijriCalendar();
}

class SelectHijriDate extends HijriCalendarEvent {
  final DateTime date;

  const SelectHijriDate(this.date);

  @override
  List<Object?> get props => [date];
}

class NextHijriMonth extends HijriCalendarEvent {
  const NextHijriMonth();
}

class PreviousHijriMonth extends HijriCalendarEvent {
  const PreviousHijriMonth();
}
class ChangeHijriLocation extends HijriCalendarEvent {
  final double latitude;
  final double longitude;

  const ChangeHijriLocation({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
    latitude,
    longitude,
  ];
}