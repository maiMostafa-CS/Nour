import '../entities/hijri_date_entity.dart';
import '../repositories/hijri_calendar_repository.dart';

class GetHijriMonth {
  final HijriCalendarRepository repository;

  GetHijriMonth(this.repository);

  List<HijriDateEntity> call({
    required int year,
    required int month,
  }) {
    return repository.getHijriMonth(
      year: year,
      month: month,
    );
  }
}