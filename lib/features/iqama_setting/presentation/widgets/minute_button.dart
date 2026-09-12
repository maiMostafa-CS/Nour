import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MinuteButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const MinuteButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE8E8CE),
      borderRadius:
      BorderRadius.circular(10.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius:
        BorderRadius.circular(10.r),
        child: SizedBox(
          width: 38.w,
          height: 38.w,
          child: Icon(
            icon,
            size: 20.sp,
            color: onPressed == null
                ? Colors.grey
                : const Color(0xFF176B5B),
          ),
        ),
      ),
    );
  }
}