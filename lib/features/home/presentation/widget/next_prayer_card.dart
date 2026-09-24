import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../prayer_times/domain/entities/prayer_times_entity.dart';

class NextPrayerCard extends StatefulWidget {
  final PrayerTimesEntity prayerTimes;
  final String timezoneName;
  final String? cityName;
  final Map<String, String>? muezzins;

  const NextPrayerCard({
    super.key,
    required this.prayerTimes,
    required this.timezoneName,
    this.cityName,
    this.muezzins,
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

  String _formatTime(tz.TZDateTime time) {
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
  }

  // ← أيقونة لكل صلاة (تُستخدم في التصميم الجديد)
  IconData _getPrayerIcon(String name) {
    switch (name) {
      case 'الفجر':
        return Icons.nights_stay_outlined;
      case 'الشروق':
        return Icons.wb_twilight;
      case 'الظهر':
        return Icons.wb_sunny_outlined;
      case 'العصر':
        return Icons.wb_sunny;
      case 'المغرب':
        return Icons.wb_twilight_outlined;
      case 'العشاء':
        return Icons.nightlight_outlined;
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {

    final now = tz.TZDateTime.now(_location);

    final prayers = [
      {'name': 'الفجر', 'time': widget.prayerTimes.fajr},
      {'name': 'الشروق', 'time': widget.prayerTimes.sunrise},
      {'name': 'الظهر', 'time': widget.prayerTimes.dhuhr},
      {'name': 'العصر', 'time': widget.prayerTimes.asr},
      {'name': 'المغرب', 'time': widget.prayerTimes.maghrib},
      {'name': 'العشاء', 'time': widget.prayerTimes.isha},
    ];

    // ═══════════════════════════════════════════════════════════
    // ← التعديل: TZDateTime بدل DateTime
    // ═══════════════════════════════════════════════════════════
    tz.TZDateTime? nextPrayerTime;
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
    final nextMuezzin = widget.muezzins?[nextPrayerName]?.trim();
    final hasMuezzin = nextMuezzin != null && nextMuezzin.isNotEmpty;
    final difference = nextPrayerTime.difference(now);
    final totalSeconds = difference.inSeconds.clamp(0, 86399);

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final remainingTime =
        '-${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    final displayCity = widget.cityName?.trim().isNotEmpty == true
        ? widget.cityName!.trim()
        : null;
    final nowInLocation = _formatTime(now);

    final nextPrayerFormatted = _formatTime(nextPrayerTime);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E4D3E).withOpacity(.35),
            blurRadius: 20.r,
            spreadRadius: 2.r,
            offset: Offset(0, 8.h),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1B5E4A),
                    Color(0xFF0E4D3E),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -20,
            top: -20,
            child: Icon(
              Icons.mosque,
              size: 120.r,
              color: Colors.white.withOpacity(.04),
            ),
          ),
          Positioned(
            right: -30,
            bottom: -30,
            child: Icon(
              Icons.star,
              size: 100.r,
              color: Colors.white.withOpacity(.04),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (displayCity != null)
                      Row(
                        children: [
                          Icon(
                            Icons.mosque,
                            size: 14.sp,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "الصلاه القادمة",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.15),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.volume_up,
                            size: 16.sp,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getPrayerIcon(nextPrayerName),
                      size: 18.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'صلاة $nextPrayerName',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // ─── العد التنازلي ───
                Text(
                  remainingTime,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5.w,
                  ),
                ),

                SizedBox(height: 4.h),

                Text(
                  'متبقي على وقت الأذان',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.sp,
                  ),
                ),

                SizedBox(height: 14.h),

                // ─── السطر السفلي: وقت الصلاة الحالي والتالي ───
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // الوقت الحالي
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_filled,
                            size: 14.sp,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'الوقت الآن: $nowInLocation',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      // وقت الصلاة القادمة
                      Row(
                        children: [
                          Text(
                            'أذان $nextPrayerName: $nextPrayerFormatted',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.access_time_filled,
                            size: 14.sp,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}