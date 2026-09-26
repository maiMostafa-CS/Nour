// lib/features/prayer_times/presentation/widgets/next_prayer_card.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/theme/app_colors.dart';
import '../../../prayer_times/domain/entities/prayer_times_entity.dart';

class NextPrayerCard extends StatefulWidget {
  final PrayerTimesEntity prayerTimes;
  final String timezoneName;
  final Map<String, String>? muezzins;

  const NextPrayerCard({
    super.key,
    required this.prayerTimes,
    required this.timezoneName,
    this.muezzins,
  });

  @override
  State<NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends State<NextPrayerCard>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // ─── Timer للـ countdown ───
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (mounted) setState(() {});
      },
    );

    // ─── Pulse animation ───
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════

  tz.Location get _location {
    try {
      return tz.getLocation(widget.timezoneName);
    } catch (_) {
      return tz.getLocation('Africa/Cairo');
    }
  }

  String _formatTime(tz.TZDateTime time) {
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
  }

  IconData _getPrayerIcon(String name) {
    switch (name) {
      case 'الفجر':
        return Icons.nights_stay_outlined;
      case 'الشروق':
        return Icons.wb_twilight;
      case 'الظهر':
        return Icons.wb_sunny_outlined;
      case 'العصر':
        return Icons.wb_sunny;
      case 'المغرب':
        return Icons.wb_twilight_outlined;
      case 'العشاء':
        return Icons.nightlight_outlined;
      default:
        return Icons.access_time;
    }
  }

  // ✨ خط زخرفي جانبي للآية
  Widget _ornamentLine() {
    return Container(
      width: 35.w,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.softGold.withOpacity(0.6),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final now = tz.TZDateTime.now(_location);

    final prayers = [
      {'name': 'الفجر', 'time': widget.prayerTimes.fajr},
      {'name': 'الشروق', 'time': widget.prayerTimes.sunrise},
      {'name': 'الظهر', 'time': widget.prayerTimes.dhuhr},
      {'name': 'العصر', 'time': widget.prayerTimes.asr},
      {'name': 'المغرب', 'time': widget.prayerTimes.maghrib},
      {'name': 'العشاء', 'time': widget.prayerTimes.isha},
    ];

    tz.TZDateTime? nextPrayerTime;
    String nextPrayerName = '';

    for (final prayer in prayers) {
      final rawTime = prayer['time'] as DateTime;
      final time = tz.TZDateTime.from(rawTime.toUtc(), _location);
      if (time.isAfter(now)) {
        nextPrayerTime = time;
        nextPrayerName = prayer['name'] as String;
        break;
      }
    }

    if (nextPrayerTime == null) {
      final fajr = tz.TZDateTime.from(
        widget.prayerTimes.fajr.toUtc(),
        _location,
      );
      nextPrayerTime = tz.TZDateTime(
        _location,
        now.year,
        now.month,
        now.day + 1,
        fajr.hour,
        fajr.minute,
        fajr.second,
      );
      nextPrayerName = 'الفجر';
    }

    // ─── المؤذن ───
    final nextMuezzin = widget.muezzins?[nextPrayerName]?.trim();
    final hasMuezzin = nextMuezzin != null && nextMuezzin.isNotEmpty;

    // ─── العد التنازلي ───
    final difference = nextPrayerTime.difference(now);
    final totalSeconds = difference.inSeconds.clamp(0, 86399);
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final remainingTime =
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    final nowInLocation = _formatTime(now);
    final nextPrayerFormatted = _formatTime(nextPrayerTime);
    final prayerIcon = _getPrayerIcon(nextPrayerName);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: AppColors.softGold.withOpacity(0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepGreen.withOpacity(.35),
              blurRadius: 22.r,
              spreadRadius: 2.r,
              offset: Offset(0, 10.h),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(.12),
              blurRadius: 6.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.emeraldGreen,
                      AppColors.deepGreen,
                      Color(0xFF093D30),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: -20,
              top: -20,
              child: Icon(
                Icons.mosque,
                size: 120.r,
                color: Colors.white.withOpacity(.04),
              ),
            ),
            Positioned(
              right: -30,
              bottom: -30,
              child: Icon(
                Icons.star,
                size: 100.r,
                color: Colors.white.withOpacity(.04),
              ),
            ),

            // ─── محتوى ───
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ═══════════════════════════════════════
                  // ✨ الآية القرآنية (بدل اسم المدينة وزرار الصوت)
                  // ═══════════════════════════════════════
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ornamentLine(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          '﴿ وَأَقِمِ الصَّلَاةَ لِذِكْرِي ﴾',
                          style: TextStyle(
                            color: AppColors.softGold.withOpacity(0.9),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Amiri',
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      _ornamentLine(),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  // ═══════════════════════════════════════
                  // اسم الصلاة
                  // ═══════════════════════════════════════
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        prayerIcon,
                        size: 20.sp,
                        color: AppColors.softGold,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'صلاة $nextPrayerName',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  // ─── فاصل ذهبي ───
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10.h),
                    height: 1,
                    width: 80.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.softGold.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // ═══════════════════════════════════════
                  // العد التنازلي
                  // ═══════════════════════════════════════
                  Text(
                    remainingTime,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.w,
                      shadows: [
                        Shadow(
                          color: AppColors.softGold.withOpacity(0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    'متبقي على وقت الأذان',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.sp,
                      letterSpacing: 0.3,
                    ),
                  ),

                  // ─── اسم المؤذن (اختياري) ───
                  if (hasMuezzin) ...[
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softGold.withOpacity(.12),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.softGold.withOpacity(.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic_none_rounded,
                            size: 12.sp,
                            color: AppColors.softGold,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'المؤذن: $nextMuezzin',
                            style: TextStyle(
                              color: AppColors.softGold,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 14.h),

                  // ═══════════════════════════════════════
                  // السطر السفلي: الوقت الحالي + وقت الأذان
                  // ═══════════════════════════════════════
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.20),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(.06),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // الوقت الحالي
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_filled,
                              size: 13.sp,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'الآن: $nowInLocation',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // فاصل رفيع
                        Container(
                          width: 1,
                          height: 14.h,
                          color: Colors.white.withOpacity(.15),
                        ),

                        // وقت الأذان
                        Row(
                          children: [
                            Text(
                              'الأذان: $nextPrayerFormatted',
                              style: TextStyle(
                                color: AppColors.softGold,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.notifications_active_outlined,
                              size: 13.sp,
                              color: AppColors.softGold,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}