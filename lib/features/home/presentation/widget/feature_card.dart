import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

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
      return _buildImageCard();
    }
    return _buildIconCard();
  }

  Widget _buildImageCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 115.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepGreen.withOpacity(0.30),
              blurRadius: 20.r,
              spreadRadius: 1.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(image!, fit: BoxFit.cover),
            ),
            // Overlay متدرج للقراءة
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.black.withOpacity(0.15),
                    ],
                  ),
                ),
              ),
            ),
            // إطار ذهبي رقيق
            Positioned.fill(
              child: Container(
                margin: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.softGold.withOpacity(0.4),
                    width: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14.h,
              bottom: 14.h,
              right: 14.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.lightGold,
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

  Widget _buildIconCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 115.h,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF8F6F0)],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.gold.withOpacity(0.20),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepGreen.withOpacity(0.08),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
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
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      subtitle,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.lightText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              width: 46.w,
              height: 46.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (iconColor ?? AppColors.emeraldGreen).withOpacity(0.15),
                    (iconColor ?? AppColors.emeraldGreen).withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: (iconColor ?? AppColors.emeraldGreen).withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.emeraldGreen,
                size: 24.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}