import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          'update_current_location'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.sp,
          ),
        ),
        content: Text(
          'location_dialog_content'.tr(),
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
              'cancel'.tr(),
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
              'refresh_location'.tr(),
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