import 'dart:math';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QiblaCompass extends StatefulWidget {
  final double qiblaDirection;
  final double? heading;

  const QiblaCompass({
    super.key,
    required this.qiblaDirection,
    required this.heading,
  });

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass> {
  bool _isAligned = false;
  DateTime? _lastVibrationTime;

  @override
  void initState() {
    super.initState();
    _checkAlignment();
  }

  @override
  void didUpdateWidget(covariant QiblaCompass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.heading != widget.heading ||
        oldWidget.qiblaDirection != widget.qiblaDirection) {
      _checkAlignment();
    }
  }

  void _checkAlignment() {
    if (widget.heading == null) {
      _isAligned = false;
      return;
    }

    final diff = ((widget.heading! - widget.qiblaDirection).abs() % 360);
    final shortestDiff = diff > 180 ? 360 - diff : diff;
    final isNowAligned = shortestDiff <= 3.0; // Within ±3 degrees of Kaaba

    if (isNowAligned && !_isAligned) {
      final now = DateTime.now();
      if (_lastVibrationTime == null ||
          now.difference(_lastVibrationTime!) >
              const Duration(milliseconds: 1000)) {
        HapticFeedback.vibrate();
        _lastVibrationTime = now;
      }
    }

    _isAligned = isNowAligned;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.heading == null) {
      return SizedBox(
        width: 300.w,
        height: 300.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF176B5B),
            ),
            SizedBox(height: 16.h),
            Text(
              'move_phone_qibla'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final angle =
        (widget.qiblaDirection - widget.heading!) * pi / 180;
    final isArabic = context.locale.languageCode == 'ar';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 300.w,
          height: 300.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 280.w,
                height: 280.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: _isAligned
                      ? Border.all(
                          color: const Color(0xFF2E7D32),
                          width: 3.w,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: _isAligned
                          ? const Color(0xFF2E7D32).withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20.r,
                      spreadRadius: _isAligned ? 5.r : 3.r,
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: CompassPainter(),
                ),
              ),

              Transform.rotate(
                angle: angle,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 70.w,
                      height: 70.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isAligned
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF176B5B),
                        boxShadow: _isAligned
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2E7D32)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 16.r,
                                  spreadRadius: 3.r,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        Icons.mosque_rounded,
                        color: Colors.white,
                        size: 35.sp,
                      ),
                    ),

                    SizedBox(height: 5.h),

                    CustomPaint(
                      size: Size(
                        35.w,
                        100.h,
                      ),
                      painter: ArrowPainter(
                        color: _isAligned
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF176B5B),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 14.w,
                height: 14.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isAligned
                      ? const Color(0xFF2E7D32)
                      : Colors.black87,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: _isAligned
                ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
                : Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: _isAligned
                  ? const Color(0xFF2E7D32)
                  : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isAligned ? Icons.check_circle : Icons.navigation_outlined,
                size: 18.sp,
                color: _isAligned
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade600,
              ),
              SizedBox(width: 8.w),
              Text(
                _isAligned
                    ? (isArabic
                        ? 'أنت باتجاه القبلة الآن'
                        : 'Facing the Qibla now')
                    : 'move_phone_qibla'.tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight:
                      _isAligned ? FontWeight.bold : FontWeight.normal,
                  color: _isAligned
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.w
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      center,
      radius - 5.w,
      paint,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final directions = [
      ['N', 0.0],
      ['E', pi / 2],
      ['S', pi],
      ['W', 3 * pi / 2],
    ];

    for (final direction in directions) {
      final text = direction[0] as String;

      final angle = direction[1] as double;

      final x = center.dx +
          cos(angle - pi / 2) *
              (radius - 30.w);

      final y = center.dy +
          sin(angle - pi / 2) *
              (radius - 30.w);

      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: text == 'N'
              ? const Color(0xFF176B5B)
              : Colors.grey.shade700,
        ),
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          x - textPainter.width / 2,
          y - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}

class ArrowPainter extends CustomPainter {
  final Color color;

  ArrowPainter({this.color = const Color(0xFF176B5B)});

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(
        size.width / 2,
        0,
      )
      ..lineTo(
        size.width,
        size.height * 0.35,
      )
      ..lineTo(
        size.width / 2,
        size.height * 0.25,
      )
      ..lineTo(
        0,
        size.height * 0.35,
      )
      ..close();

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}