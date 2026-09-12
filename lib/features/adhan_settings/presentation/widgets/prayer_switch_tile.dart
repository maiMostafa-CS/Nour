import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrayerSwitchTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const PrayerSwitchTile({
    required this.name,
    required this.icon,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        clipBehavior: Clip.antiAlias,
        child: SwitchListTile(
          value: enabled,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF176B5B),
          activeTrackColor:
          const Color(0xFF176B5B).withValues(alpha: 0.35),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 4.h,
          ),
          secondary: Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8CE),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF176B5B),
              size: 24.sp,
            ),
          ),
          title: Text(
            name,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            enabled ? 'الأذان مفعّل' : 'الأذان متوقف',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}
