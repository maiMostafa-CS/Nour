import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HijriCalendarHeader extends StatelessWidget {
  final String monthName;
  final int year;

  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const HijriCalendarHeader({
    super.key,
    required this.monthName,
    required this.year,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onNext,
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 28.sp,
          ),
        ),

        Column(
          children: [
            Text(
              monthName,
              style: TextStyle(
                fontSize: 21.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 4.h),

            Text(
              '$year هـ',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),

        IconButton(
          onPressed: onPrevious,
          icon: Icon(
            Icons.chevron_right_rounded,
            size: 28.sp,
          ),
        ),
      ],
    );
  }
}