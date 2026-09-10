import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QiblaInfoCard extends StatelessWidget {
  final double qiblaDirection;
  final double latitude;
  final double longitude;

  const QiblaInfoCard({
    super.key,
    required this.qiblaDirection,
    required this.latitude,
    required this.longitude,
  });

  String get directionText {
    if (qiblaDirection >= 337.5 ||
        qiblaDirection < 22.5) {
      return 'شمال';
    }

    if (qiblaDirection < 67.5) {
      return 'شمال شرق';
    }

    if (qiblaDirection < 112.5) {
      return 'شرق';
    }

    if (qiblaDirection < 157.5) {
      return 'جنوب شرق';
    }

    if (qiblaDirection < 202.5) {
      return 'جنوب';
    }

    if (qiblaDirection < 247.5) {
      return 'جنوب غرب';
    }

    if (qiblaDirection < 292.5) {
      return 'غرب';
    }

    return 'شمال غرب';
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15.r,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45.w,
                height: 45.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF176B5B)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.explore_rounded,
                  color: const Color(0xFF176B5B),
                  size: 24.sp,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Text(
                  'اتجاه القبلة',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Text(
                '${qiblaDirection.toStringAsFixed(0)}°',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF176B5B),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          const Divider(),

          SizedBox(height: 8.h),

          Row(
            children: [
              Icon(
                Icons.navigation_rounded,
                size: 20.sp,
                color: Colors.grey,
              ),

              SizedBox(width: 8.w),

              Text(
                directionText,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),

              const Spacer(),

              Text(
                '${latitude.toStringAsFixed(4)}, '
                    '${longitude.toStringAsFixed(4)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}