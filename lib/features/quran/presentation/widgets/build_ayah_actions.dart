import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'ayah_action_button.dart';

class AyahActions extends StatelessWidget {
  final int surahNumber;
  final int verseNumber;
  final String surahName;

  final bool isPlaying;
  final bool isPaused;

  final String? reciterName;

  final VoidCallback? onListen;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onReciter;
  final VoidCallback? onTafsir;
  final VoidCallback? onTranslate;
  final VoidCallback? onClose;

  const AyahActions({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
    required this.surahName,
    this.isPlaying = false,
    this.isPaused = false,
    this.reciterName,
    this.onListen,
    this.onPause,
    this.onResume,
    this.onReciter,
    this.onTafsir,
    this.onTranslate,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: .25),
      borderRadius: BorderRadius.circular(18.r),
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFCF5D7),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: const Color(0xFF8B5A2B).withValues(alpha: .30),
            width: 1,
          ),
        ),
        child: Row(
          children: [
// ==================================================
// Ayah number
// ==================================================

            Container(
              width: 36.w,
              height: 36.w,
              decoration: const BoxDecoration(
                color: Color(0xFF8B5A2B),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$verseNumber',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    surahName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    reciterName ?? 'اختر القارئ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: const Color(0xFF777777),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 2.w),

// ==================================================
// Play / Pause / Resume
// ==================================================

            AyahActionButton(
              icon: isPlaying
                  ? Icons.pause_circle_outline
                  : isPaused
                      ? Icons.play_circle_outline
                      : Icons.play_circle_outline,
              tooltip: isPlaying
                  ? 'إيقاف مؤقت'
                  : isPaused
                      ? 'استكمال'
                      : 'استماع',
              iconColor: const Color(0xFF176B5B),
              onPressed: isPlaying
                  ? (onPause ?? () {})
                  : isPaused
                      ? (onResume ?? () {})
                      : (onListen ?? () {}),
            ),

// ==================================================
// Select reciter
// ==================================================

            AyahActionButton(
              icon: Icons.record_voice_over_outlined,
              tooltip: 'اختيار القارئ',
              iconColor: const Color(0xFF8B5A2B),
              onPressed: onReciter ?? () {},
            ),

// ==================================================
// Tafsir
// ==================================================

            AyahActionButton(
              icon: Icons.menu_book_outlined,
              tooltip: 'التفسير',
              iconColor: const Color(0xFF8B5A2B),
              onPressed: onTafsir ?? () {},
            ),

// ==================================================
// Translation
// ==================================================

            AyahActionButton(
              icon: Icons.g_translate_outlined,
              tooltip: 'الترجمة',
              iconColor: const Color(0xFF8B5A2B),
              onPressed: onTranslate ?? () {},
            ),

// ==================================================
// Close
// ==================================================

            AyahActionButton(
              icon: Icons.close,
              tooltip: 'إغلاق',
              iconColor: const Color(0xFF666666),
              onPressed: () {
                onClose?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
