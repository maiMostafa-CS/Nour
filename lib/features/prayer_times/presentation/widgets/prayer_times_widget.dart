import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/prayer_times_entity.dart';

class PrayerTimesWidget extends StatefulWidget {
  final PrayerTimesEntity prayerTimes;

  const PrayerTimesWidget({
    super.key,
    required this.prayerTimes,
  });

  @override
  State<PrayerTimesWidget> createState() =>
      _PrayerTimesWidgetState();
}

class _PrayerTimesWidgetState
    extends State<PrayerTimesWidget> {
  DateTime _now = DateTime.now();

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (!mounted) return;

        setState(() {
          _now = DateTime.now();
        });
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
    final prayers = [
      {
        'name': 'الفجر',
        'time': widget.prayerTimes.fajr,
        'icon': Icons.wb_twilight,
      },
      {
        'name': 'الشروق',
        'time': widget.prayerTimes.sunrise,
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'name': 'الظهر',
        'time': widget.prayerTimes.dhuhr,
        'icon': Icons.wb_sunny,
      },
      {
        'name': 'العصر',
        'time': widget.prayerTimes.asr,
        'icon': Icons.wb_cloudy_outlined,
      },
      {
        'name': 'المغرب',
        'time': widget.prayerTimes.maghrib,
        'icon': Icons.nights_stay_outlined,
      },
      {
        'name': 'العشاء',
        'time': widget.prayerTimes.isha,
        'icon': Icons.nightlight_outlined,
      },
    ];

    int activeIndex = -1;

    for (int i = 0; i < prayers.length; i++) {
      final prayerTime =
      prayers[i]['time'] as DateTime;

      if (prayerTime.isAfter(_now)) {
        activeIndex = i;
        break;
      }
    }

    if (activeIndex == -1) {
      activeIndex = 0;
    }

    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        physics: const BouncingScrollPhysics(),
        itemCount: prayers.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final prayer = prayers[index];

          return _buildPrayerItem(
            prayer,
            isActive: index == activeIndex,
          );
        },
      ),
    );
  }

  Widget _buildPrayerItem(
      Map<String, dynamic> prayer, {
        bool isActive = false,
      }) {
    return Container(
      width: 49,
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF176B5B)
            : const Color(0xFFF5F0E6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            prayer['icon'] as IconData,
            size: 22,
            color: isActive
                ? Colors.white
                : const Color(0xFF176B5B),
          ),
          const SizedBox(height: 5),
          Text(
            prayer['name'] as String,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? Colors.white
                  : const Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _formatPrayerTime(
              prayer['time'] as DateTime,
            ),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive
                  ? Colors.white
                  : const Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrayerTime(DateTime time) {
    return DateFormat(
     " hh:mm",
    ).format(time);
  }
}