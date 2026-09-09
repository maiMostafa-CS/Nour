import '../entities/hijri_date_entity.dart';
import '../repositories/hijri_calendar_repository.dart';

class GetHijriDate {
  final HijriCalendarRepository repository;

  GetHijriDate(this.repository);

  HijriDateEntity call(DateTime date) {
    return repository.getHijriDate(date);
  }
}