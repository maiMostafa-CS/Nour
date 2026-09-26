// lib/features/adhan/presentation/widgets/adhan_reciter_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/adhan_reciter_entity.dart';

class AdhanReciterTile extends StatelessWidget {
  final AdhanReciterEntity reciter;
  final bool isSelected;
  final bool isPlaying;
  final VoidCallback onSelect;
  final VoidCallback onTogglePreview;

  const AdhanReciterTile({
    super.key,
    required this.reciter,
    required this.isSelected,
    required this.isPlaying,
    required this.onSelect,
    required this.onTogglePreview,
  });

  static const _primaryColor = Color(0xFF176B5B);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: const Offset(0, 3),
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── أيقونة الميكروفون
            Container(
              width: 52.w,
              height: 52.w,
              decoration: const BoxDecoration(
                color: Color(0xFFE8E8CE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic,
                color: _primaryColor,
                size: 27.sp,
              ),
            ),

            SizedBox(width: 14.w),

            // ── الاسم + الحالة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reciter.name,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    isSelected ? 'المؤذن المختار' : 'اضغط للاختيار',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // ── زر التشغيل / الإيقاف
            IconButton(
              onPressed: onTogglePreview,
              icon: Icon(
                isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
                size: 38.sp,
                color: _primaryColor,
              ),
            ),

            SizedBox(width: 4.w),

            // ── علامة الصح
            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: isSelected ? _primaryColor : Colors.grey,
              size: 27.sp,
            ),
          ],
        ),
      ),
    );
  }
}