import 'package:hijri/hijri_calendar.dart';

String getCurrentHijriDate() {
  final hijri = HijriCalendar.fromDate(DateTime.now());

  const monthNames = [
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

  const weekDays = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  final dayName = weekDays[DateTime.now().weekday - 1];

  return '$dayName، ${hijri.hDay} ${monthNames[hijri.hMonth - 1]} ${hijri.hYear} هـ';
}  // ------------------------------------------------------------
