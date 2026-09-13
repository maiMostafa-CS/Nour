import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../prayer_times/domain/entities/prayer_times_entity.dart';

class NextPrayerCard extends StatefulWidget {
  final PrayerTimesEntity prayerTimes;
  final String timezoneName;
  final String? cityName;   // ← جديد: اسم المدينة (اختياري)

  const NextPrayerCard({
    super.key,
    required this.prayerTimes,
    required this.timezoneName,
    this.cityName,
  });

  @override
  State<NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends State<NextPrayerCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  tz.Location get _location {
    try {
      return tz.getLocation(widget.timezoneName);
    } catch (_) {
      return tz.getLocation('Africa/Cairo');
    }
  }

  // ✅ تنسيق الوقت بشكل 12 ساعة (مثلاً 4:50 PM)
  String _formatTime(tz.TZDateTime time) {
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
  }

  // ✅ هل المكان المختار مختلف عن توقيت الجهاز؟
  bool get _isDifferentTimezone {
    return widget.timezoneName != tz.local.name;
  }

  @override
  Widget build(BuildContext context) {
    final now = tz.TZDateTime.now(_location);

    final prayers = [
      {'name': 'الفجر',   'time': widget.prayerTimes.fajr},
      {'name': 'الشروق',  'time': widget.prayerTimes.sunrise},
      {'name': 'الظهر',   'time': widget.prayerTimes.dhuhr},
      {'name': 'العصر',   'time': widget.prayerTimes.asr},
      {'name': 'المغرب',  'time': widget.prayerTimes.maghrib},
      {'name': 'العشاء',  'time': widget.prayerTimes.isha},
    ];

    DateTime? nextPrayerTime;
    String nextPrayerName = '';

    for (final prayer in prayers) {
      final rawTime = prayer['time'] as DateTime;
      final time = tz.TZDateTime.from(rawTime.toUtc(), _location);
      if (time.isAfter(now)) {
        nextPrayerTime = time;
        nextPrayerName = prayer['name'] as String;
        break;
      }
    }

    if (nextPrayerTime == null) {
      final fajr = tz.TZDateTime.from(
        widget.prayerTimes.fajr.toUtc(),
        _location,
      );

      nextPrayerTime = tz.TZDateTime(
        _location,
        now.year,
        now.month,
        now.day + 1,
        fajr.hour,
        fajr.minute,
        fajr.second,
      );

      nextPrayerName = 'الفجر';
    }

    final difference = nextPrayerTime.difference(now);
    final totalSeconds = difference.inSeconds.clamp(0, 86399);

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final remainingTime =
        '-${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    // ✅ اسم المكان لعرضه
    final displayCity = widget.cityName?.trim().isNotEmpty == true
        ? widget.cityName!.trim()
        : null;

    final nowInLocation = _formatTime(now);

    return Container(
      width: double.infinity,
      height: 180.h,   // ← زوّدنا الارتفاع شوية عشان السطر الجديد
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/islamic_night_city.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(.15),
                    Colors.black.withOpacity(.45),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'الصلاة القادمة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        nextPrayerName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        remainingTime,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.w,
                        ),
                      ),
                      Text(
                        'المتبقي على الأذان',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16.sp,
                        ),
                      ),

                      // ✅ السطر الجديد: يظهر بس لو المكان مختلف عن توقيت الجهاز
                      if (_isDifferentTimezone) ...[
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.15),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            displayCity != null
                                ? 'الوقت الآن في  $displayCity: $nowInLocation'
                                : 'الآن في المكان المختار: $nowInLocation',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}