import 'dart:async';

import 'package:flutter/material.dart';

import '../../../prayer_times/domain/entities/prayer_times_entity.dart';

class NextPrayerCard extends StatefulWidget {
  final PrayerTimesEntity prayerTimes;

  const NextPrayerCard({
    super.key,
    required this.prayerTimes,
  });

  @override
  State<NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends State<NextPrayerCard> {
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (mounted) {
          setState(() {
            _now = DateTime.now();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = _now;

    final prayers = [
      {
        'name': 'الفجر',
        'time': widget.prayerTimes.fajr,
      },
      {
        'name': 'الظهر',
        'time': widget.prayerTimes.dhuhr,
      },
      {
        'name': 'العصر',
        'time': widget.prayerTimes.asr,
      },
      {
        'name': 'المغرب',
        'time': widget.prayerTimes.maghrib,
      },
      {
        'name': 'العشاء',
        'time': widget.prayerTimes.isha,
      },
    ];

    DateTime? nextPrayerTime;
    String nextPrayerName = '';

    for (final prayer in prayers) {
      final time = prayer['time'] as DateTime;

      if (time.isAfter(now)) {
        nextPrayerTime = time;
        nextPrayerName = prayer['name'] as String;
        break;
      }
    }


    if (nextPrayerTime == null) {
      final fajr = widget.prayerTimes.fajr;

      nextPrayerTime = DateTime(
        now.year,
        now.month,
        now.day + 1,
        fajr.hour,
        fajr.minute,
        fajr.second,
      );

      nextPrayerName = 'الفجر';
    }

    final difference = nextPrayerTime.difference(now);

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    final remainingTime =
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // الصورة
          Positioned.fill(
            child: Image.asset(
              'assets/images/islamic_night_city.png',
              fit: BoxFit.cover,
            ),
          ),

          // Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(.15),
                    Colors.black.withOpacity(.45),
                  ],
                ),
              ),
            ),
          ),

          // المحتوى
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'الصلاة القادمة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    'صلاة $nextPrayerName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    remainingTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const Text(
                    'المتبقي على الأذان',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}