import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ErrorView extends StatelessWidget {
  final String? message;

  const ErrorView({
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 50.sp,
              color: Colors.redAccent,
            ),
            SizedBox(height: 12.h),
            Text(
              'حدث خطأ أثناء تحميل إعدادات الأذان',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (message != null) ...[
              SizedBox(height: 8.h),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}