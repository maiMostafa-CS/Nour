import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AyahActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color iconColor;
  final VoidCallback onPressed;

  const AyahActionButton({
    required this.icon,
    required this.tooltip,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      splashRadius: 22,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(
        minWidth: 42.w,
        minHeight: 42.w,
      ),
      icon: Icon(
        icon,
        color: iconColor,
        size: 28.sp,
      ),
    );
  }
}