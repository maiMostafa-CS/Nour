import 'package:equatable/equatable.dart';

class HijriDateEntity extends Equatable {
  final int day;
  final int month;
  final int year;
  final String monthName;
  final DateTime gregorianDate;
  final bool isToday;

  const HijriDateEntity({
    required this.day,
    required this.month,
    required this.year,
    required this.monthName,
    required this.gregorianDate,
    required this.isToday,
  });

  @override
  List<Object?> get props => [
    day,
    month,
    year,
    monthName,
    gregorianDate,
    isToday,
  ];
}