import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CurrentLocationCard extends StatelessWidget {
  final VoidCallback onTap;

  const CurrentLocationCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                child: Icon(
                  Icons.my_location,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24.sp,
                ),
              ),

              SizedBox(width: 14.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Location',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      'Use your device location',
                      style: TextStyle(
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right,
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}