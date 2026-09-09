import '../../domain/entities/hijri_date_entity.dart';

class HijriDateModel extends HijriDateEntity {
  const HijriDateModel({
    required super.day,
    required super.month,
    required super.year,
    required super.monthName,
    required super.gregorianDate,
    required super.isToday,
  });
}