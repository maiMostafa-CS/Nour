import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../prayer_times/domain/entities/prayer_times_entity.dart';

class PrayerTimesCard extends StatelessWidget {
  final PrayerTimesEntity prayerTimes;
  final String timezoneName;

  const PrayerTimesCard({
    super.key,
    required this.prayerTimes,
    required this.timezoneName,
  });

  String _formatTime(DateTime time) {
    final location = tz.getLocation(timezoneName);
    final localTime = tz.TZDateTime.from(time, location);

    final hour = localTime.hour == 0
        ? 12
        : localTime.hour > 12
            ? localTime.hour - 12
            : localTime.hour;

    final minute = localTime.minute.toString().padLeft(2, '0');
    final period = localTime.hour >= 12 ? 'م' : 'ص';

    return '$hour:$minute $period';
  }

  Widget _buildPrayer(
    String name,
    DateTime time,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22.sp,
            color: const Color(0xFF176B5B),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontSize: 15.sp),
            ),
          ),
          Text(
            _formatTime(time),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مواقيت الصلاة',
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          _buildPrayer('الفجر', prayerTimes.fajr, Icons.wb_twilight),
          _buildPrayer('الشروق', prayerTimes.sunrise, Icons.wb_sunny_outlined),
          _buildPrayer('الظهر', prayerTimes.dhuhr, Icons.wb_sunny),
          _buildPrayer('العصر', prayerTimes.asr, Icons.sunny_snowing),
          _buildPrayer('المغرب', prayerTimes.maghrib, Icons.wb_twilight),
          _buildPrayer('العشاء', prayerTimes.isha, Icons.nightlight_round),
        ],
      ),
    );
  }
}
