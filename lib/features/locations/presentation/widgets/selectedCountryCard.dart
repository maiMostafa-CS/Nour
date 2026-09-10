import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectedCountryCard extends StatelessWidget {
  final String countryName;
  final VoidCallback onBack;

  const SelectedCountryCard({
    super.key,
    required this.countryName,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(18.r),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: Icon(
                Icons.arrow_back,
                size: 24.sp,
              ),
            ),

            SizedBox(width: 8.w),

            Icon(
              Icons.public,
              size: 28.sp,
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Country',
                    style: TextStyle(
                      fontSize: 12.sp,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  Text(
                    countryName,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}