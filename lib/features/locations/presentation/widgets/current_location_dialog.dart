import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

Future<bool> showCurrentLocationDialog(
    BuildContext context,
    )
async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        icon: Icon(
          Icons.location_on,
          size: 42.sp,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          'تحديث الموقع الحالي',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.sp,
          ),
        ),
        content: Text(
          'سيتم تحديث موقعك الحالي.\n\n'
              'يرجى التأكد من تفعيل الموقع/GPS '
              'على جهازك.\n\n'
              'إذا كان الموقع غير مفعّل، يرجى تفعيله '
              'قبل المتابعة.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontSize: 14.sp,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: Text(
              'تحديث الموقع',
              style: TextStyle(
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      );
    },
  );

  return result == true;
}