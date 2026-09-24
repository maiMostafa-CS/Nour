import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/prayer_times_entity.dart';

class PrayerTimesWidget extends StatefulWidget {
  final PrayerTimesEntity prayerTimes;
  final String timezoneName;

  const PrayerTimesWidget({
    super.key,
    required this.prayerTimes,
    required this.timezoneName,
  });

  @override
  State<PrayerTimesWidget> createState() => _PrayerTimesWidgetState();
}

class _PrayerTimesWidgetState extends State<PrayerTimesWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
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

  DateTime _localTime(DateTime time) {
    return tz.TZDateTime.from(time, _location);
  }

  String _formatPrayerTime(DateTime time) {
    final localTime = _localTime(time);

    final hour = localTime.hour == 0
        ? 12
        : localTime.hour > 12
        ? localTime.hour - 12
        : localTime.hour;

    final minute = localTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final now = tz.TZDateTime.now(_location);

    final prayers = [
      {
        'name': 'الفجر',
        'time': widget.prayerTimes.fajr,
        'icon': Icons.wb_twilight,
      },
      {
        'name': 'الشروق',
        'time': widget.prayerTimes.sunrise,
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'name': 'الظهر',
        'time': widget.prayerTimes.dhuhr,
        'icon': Icons.wb_sunny,
      },
      {
        'name': 'العصر',
        'time': widget.prayerTimes.asr,
        'icon': Icons.wb_cloudy_outlined,
      },
      {
        'name': 'المغرب',
        'time': widget.prayerTimes.maghrib,
        'icon': Icons.nights_stay_outlined,
      },
      {
        'name': 'العشاء',
        'time': widget.prayerTimes.isha,
        'icon': Icons.nightlight_outlined,
      },
    ];

    int activeIndex = -1;

    for (int i = 0; i < prayers.length; i++) {
      final prayerTime = prayers[i]['time'] as DateTime;

      if (prayerTime.isAfter(now)) {
        activeIndex = i;
        break;
      }
    }

    if (activeIndex == -1) activeIndex = 0;

    return SizedBox(
      height: 86.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: prayers.length,
        separatorBuilder: (_, __) => SizedBox(width: 7.w),
        itemBuilder: (context, index) {
          final prayer = prayers[index];

          return _buildPrayerItem(
            prayer,
            isActive: index == activeIndex,
          );
        },
      ),
    );
  }

  Widget _buildPrayerItem(
    Map<String, dynamic> prayer, {
    bool isActive = false,
  }) {
    return Container(
      width: 52.w,
      padding: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF176B5B)
            : const Color(0xFFF5F0E6),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? const Color(0xFF176B5B).withOpacity(.35)
                : Colors.black.withOpacity(.10),
            blurRadius: isActive ? 10.r : 6.r,
            spreadRadius: isActive ? 1.r : 0,
            offset: Offset(0, isActive ? 4.h : 2.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            prayer['icon'] as IconData,
            size: 22.sp,
            color: isActive
                ? Colors.white
                : const Color(0xFF176B5B),
          ),
          SizedBox(height: 4.h),
          Text(
            prayer['name'] as String,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? Colors.white
                  : const Color(0xFF222222),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            _formatPrayerTime(prayer['time'] as DateTime),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: isActive
                  ? Colors.white
                  : const Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }
}
