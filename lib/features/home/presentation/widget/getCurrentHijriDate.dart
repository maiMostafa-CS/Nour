import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:hijri/hijri_calendar.dart';

String getCurrentHijriDate([BuildContext? context]) {
  final isArabic = context == null || context.locale.languageCode == 'ar';
  final hijri = HijriCalendar.fromDate(DateTime.now());

  const monthNamesAr = [
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

  const weekDaysAr = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  const monthNamesEn = [
    'Muharram',
    'Safar',
    'Rabi\' al-Awwal',
    'Rabi\' al-Thani',
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    'Sha\'ban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qi\'dah',
    'Dhu al-Hijjah',
  ];

  const weekDaysEn = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final weekdayIndex = DateTime.now().weekday - 1;
  final monthIndex = (hijri.hMonth - 1).clamp(0, 11);

  if (isArabic) {
    final dayName = weekDaysAr[weekdayIndex];
    return '$dayName، ${hijri.hDay} ${monthNamesAr[monthIndex]} ${hijri.hYear} هـ';
  } else {
    final dayName = weekDaysEn[weekdayIndex];
    return '$dayName, ${hijri.hDay} ${monthNamesEn[monthIndex]} ${hijri.hYear} AH';
  }
}
