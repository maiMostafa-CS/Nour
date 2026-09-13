import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entity/location_entity.dart';
import 'coordinateRow.dart';

void showLocationConfirmation(
    BuildContext context,
    LocationEntity location,
    VoidCallback onConfirm,
    ) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24.r),
      ),
    ),
    builder: (_) {
      return LocationConfirmationBottomSheet(
        location: location,
        onConfirm: onConfirm,
      );
    },
  );
}

class LocationConfirmationBottomSheet
    extends StatelessWidget {
  final LocationEntity location;
  final VoidCallback onConfirm;

  const LocationConfirmationBottomSheet({
    super.key,
    required this.location,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius:
                BorderRadius.circular(10.r),
              ),
            ),

            SizedBox(height: 24.h),

            Icon(
              Icons.location_on,
              size: 50.sp,
            ),

            SizedBox(height: 16.h),

            Text(
              location.city,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 6.h),

            Text(
              location.country,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
              ),
            ),

            SizedBox(height: 20.h),

            CoordinateRow(
              label: 'خط العرض',
              value: location.latitude.toString(),
            ),

            CoordinateRow(
              label: 'خط الطول',
              value: location.longitude.toString(),
            ),

            SizedBox(height: 24.h),

            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: onConfirm,
                child: Text(
                  'استخدام هذا الموقع',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 8.h),

            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}