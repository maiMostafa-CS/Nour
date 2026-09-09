import '../entities/hijri_date_entity.dart';

abstract class HijriCalendarRepository {
  HijriDateEntity getHijriDate(DateTime date);

  List<HijriDateEntity> getHijriMonth({
    required int year,
    required int month,
  });
}