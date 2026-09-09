import '../../domain/entities/hijri_date_entity.dart';
import '../../domain/repositories/hijri_calendar_repository.dart';
import '../datasources/hijri_calendar_local_data_source.dart';

class HijriCalendarRepositoryImpl
    implements HijriCalendarRepository {
  final HijriCalendarLocalDataSource localDataSource;

  HijriCalendarRepositoryImpl({
    required this.localDataSource,
  });

  @override
  HijriDateEntity getHijriDate(DateTime date) {
    return localDataSource.getHijriDate(date);
  }

  @override
  List<HijriDateEntity> getHijriMonth({
    required int year,
    required int month,
  }) {
    return localDataSource.getHijriMonth(
      year: year,
      month: month,
    );
  }
}