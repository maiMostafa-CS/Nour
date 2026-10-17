import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HijriWeekDays extends StatelessWidget {
  const HijriWeekDays({super.key});

  @override
  Widget build(BuildContext context) {
    final days = [
      'sun'.tr(),
      'mon'.tr(),
      'tue'.tr(),
      'wed'.tr(),
      'thu'.tr(),
      'fri'.tr(),
      'sat'.tr(),
    ];

    return Row(
      children: days
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}