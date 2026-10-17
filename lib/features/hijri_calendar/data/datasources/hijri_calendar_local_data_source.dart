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
      final hijri = HijriCalendar.fromDate(date);
      final today = DateTime.now();

      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;

      return HijriDateModel(
        day: hijri.hDay,
        month: hijri.hMonth,
        year: hijri.hYear,
        monthName: monthNames[(hijri.hMonth - 1) % 12],
        gregorianDate: DateTime(
          date.year,
          date.month,
          date.day,
        ),
        isToday: isToday,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR in getHijriDate: $e\n$stackTrace');
      rethrow;
    }
  }

  @override
  List<HijriDateModel> getHijriMonth({
    required int year,
    required int month,
  }) {
    try {
      final h = HijriCalendar();
      final daysInMonth = h.getDaysInMonth(year, month);
      final today = DateTime.now();
      final List<HijriDateModel> dates = [];

      for (int day = 1; day <= daysInMonth; day++) {
        final gregorianDate = h.hijriToGregorian(year, month, day);
        final isToday = gregorianDate.year == today.year &&
            gregorianDate.month == today.month &&
            gregorianDate.day == today.day;

        dates.add(
          HijriDateModel(
            day: day,
            month: month,
            year: year,
            monthName: monthNames[(month - 1) % 12],
            gregorianDate: gregorianDate,
            isToday: isToday,
          ),
        );
      }

      return dates;
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR in getHijriMonth: $e\n$stackTrace');
      rethrow;
    }
  }
}