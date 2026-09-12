import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class InfoCard extends StatelessWidget {
  const InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8CE),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.volume_up_outlined,
            size: 28.sp,
            color: const Color(0xFF176B5B),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'اختر أوقات الصلاة التي تريد تشغيل الأذان فيها.',
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
