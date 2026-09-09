import 'package:flutter/foundation.dart';
import 'package:hijri/hijri_calendar.dart';

import '../models/hijri_date_model.dart';

abstract class HijriCalendarLocalDataSource {
  HijriDateModel getHijriDate(DateTime date);

  List<HijriDateModel> getHijriMonth({
    required int year,
    required int month,
  });
}

class HijriCalendarLocalDataSourceImpl
    implements HijriCalendarLocalDataSource {
  static const List<String> monthNames = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  @override
  HijriDateModel getHijriDate(DateTime date) {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📅 getHijriDate');
      debugPrint('Gregorian Date: $date');

      final hijri = HijriCalendar.fromDate(date);

      debugPrint(
        'Hijri: ${hijri.hDay}/${hijri.hMonth}/${hijri.hYear}',
      );

      final today = DateTime.now();

      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;

      return HijriDateModel(
        day: hijri.hDay,
        month: hijri.hMonth,
        year: hijri.hYear,
        monthName: monthNames[hijri.hMonth - 1],
        gregorianDate: DateTime(
          date.year,
          date.month,
          date.day,
        ),
        isToday: isToday,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR in getHijriDate');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');

      rethrow;
    }
  }

  @override
  List<HijriDateModel> getHijriMonth({
    required int year,
    required int month,
  }) {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📅 getHijriMonth');
      debugPrint('Requested Hijri: $month/$year');

      final List<HijriDateModel> dates = [];

      final firstDay = _findFirstGregorianDate(

        year: year,
        month: month,
      );

      debugPrint('✅ First Gregorian Day: $firstDay');

      final daysInMonth = _getDaysInHijriMonth(
        year: year,
        month: month,
        firstDay: firstDay,
      );

      debugPrint('📊 Days in Hijri Month: $daysInMonth');

      for (int i = 0; i < daysInMonth; i++) {
        final gregorianDate = DateTime(
          firstDay.year,
          firstDay.month,
          firstDay.day + i,
        );

        final hijri = HijriCalendar.fromDate(gregorianDate);

        debugPrint(
          'Day $i → '
              '${gregorianDate.toString().split(' ').first} '
              '=> ${hijri.hDay}/${hijri.hMonth}/${hijri.hYear}',
        );

        if (hijri.hYear != year || hijri.hMonth != month) {
          debugPrint('⚠️ Hijri month changed, stopping...');
          break;
        }

        final today = DateTime.now();

        final isToday = gregorianDate.year == today.year &&
            gregorianDate.month == today.month &&
            gregorianDate.day == today.day;

        dates.add(
          HijriDateModel(
            day: hijri.hDay,
            month: hijri.hMonth,
            year: hijri.hYear,
            monthName: monthNames[hijri.hMonth - 1],
            gregorianDate: gregorianDate,
            isToday: isToday,
          ),
        );
      }

      debugPrint('✅ Total dates: ${dates.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return dates;
    } catch (e, stackTrace) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ ERROR in getHijriMonth');
      debugPrint('Requested Year: $year');
      debugPrint('Requested Month: $month');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      rethrow;
    }
  }

  DateTime _findFirstGregorianDate({
    required int year,
    required int month,
  }) {
    try {
      debugPrint('🔎 Searching first Gregorian date...');
      debugPrint('Hijri Year: $year');
      debugPrint('Hijri Month: $month');

      final estimatedGregorianYear =
      (year * 0.970224 + 621.57).round();

      debugPrint(
        'Estimated Gregorian Year: $estimatedGregorianYear',
      );

      DateTime startDate = DateTime(
        estimatedGregorianYear,
        1,
        1,
      );

      debugPrint(
        'Starting Search Date: $startDate',
      );

      // نبحث في سنة كاملة + هامش
      for (int i = 0; i < 450; i++) {
        final date = startDate.add(
          Duration(days: i),
        );

        final hijri = HijriCalendar.fromDate(date);

        if (hijri.hYear == year &&
            hijri.hMonth == month) {
          debugPrint(
            '🎯 Found Hijri month at: $date',
          );

          // نرجع للخلف لحد أول يوم في الشهر
          DateTime firstDay = date;

          while (true) {
            final previousDay = firstDay.subtract(
              const Duration(days: 1),
            );

            final previousHijri =
            HijriCalendar.fromDate(previousDay);

            if (previousHijri.hYear != year ||
                previousHijri.hMonth != month) {
              debugPrint(
                '✅ First Gregorian Date: $firstDay',
              );

              return firstDay;
            }

            firstDay = previousDay;
          }
        }
      }

      throw Exception(
        'Unable to find Hijri month $month/$year',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR in _findFirstGregorianDate');
      debugPrint('Year: $year');
      debugPrint('Month: $month');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');

      rethrow;
    }
  }

  int _getDaysInHijriMonth({
    required int year,
    required int month,
    required DateTime firstDay,
  }) {
    try {
      debugPrint('🔎 Calculating days in Hijri month...');
      debugPrint('First Day: $firstDay');

      for (int i = 0; i < 35; i++) {
        final date = firstDay.add(
          Duration(days: i),
        );

        final hijri = HijriCalendar.fromDate(date);

        debugPrint(
          '📆 Day $i: '
              '${date.toString().split(' ').first} '
              '=> ${hijri.hDay}/${hijri.hMonth}/${hijri.hYear}',
        );

        if (hijri.hYear != year ||
            hijri.hMonth != month) {
          debugPrint(
            '✅ Month ended after $i days',
          );

          return i;
        }
      }

      debugPrint(
        '⚠️ Could not detect month end, returning 30',
      );

      return 30;
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR in _getDaysInHijriMonth');
      debugPrint('Year: $year');
      debugPrint('Month: $month');
      debugPrint('FirstDay: $firstDay');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');

      rethrow;
    }
  }
}