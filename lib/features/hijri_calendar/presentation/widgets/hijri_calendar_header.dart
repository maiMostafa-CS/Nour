import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HijriCalendarHeader extends StatelessWidget {
  final String monthName;
  final int year;

  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onTitleTap;

  const HijriCalendarHeader({
    super.key,
    required this.monthName,
    required this.year,
    required this.onPrevious,
    required this.onNext,
    this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    final hijriSuffix = 'hijri_suffix'.tr();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onNext,
          tooltip: 'next_month'.tr(),
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 28.sp,
            color: const Color(0xFF176B5B),
          ),
        ),

        InkWell(
          onTap: onTitleTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      monthName,
                      style: TextStyle(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF176B5B),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 24.sp,
                      color: const Color(0xFF176B5B),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF176B5B).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '$year $hijriSuffix',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF176B5B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        IconButton(
          onPressed: onPrevious,
          tooltip: 'previous_month'.tr(),
          icon: Icon(
            Icons.chevron_right_rounded,
            size: 28.sp,
            color: const Color(0xFF176B5B),
          ),
        ),
      ],
    );
  }
}