import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;

  final String? image;

  final IconData? icon;
  final Color? iconColor;

  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.image,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 110.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF176B5B).withOpacity(.30),
                blurRadius: 18.r,
                spreadRadius: 2.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  image!,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12.h,
                bottom: 12.h,
                right: 12.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      SizedBox(height: 5.h),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Icon-based card
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110.h,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F0E9),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: const Color(0xFFEDEBE5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.025),
              blurRadius: 6.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF222222),
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 5.h),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              width: 42.w,
              height: 42.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (iconColor ?? Colors.grey).withOpacity(.08),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.grey,
                size: 25.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}