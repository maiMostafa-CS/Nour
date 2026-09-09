import 'package:flutter/material.dart';

import '../../../prayer_times/domain/entities/prayer_times_entity.dart';

class PrayerTimesCard extends StatelessWidget {
  final PrayerTimesEntity prayerTimes;

  const PrayerTimesCard({
    super.key,
    required this.prayerTimes,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour == 0
        ? 12
        : time.hour > 12
        ? time.hour - 12
        : time.hour;

    final minute =
    time.minute.toString().padLeft(2, '0');

    final period = time.hour >= 12 ? 'م' : 'ص';

    return '$hour:$minute $period';
  }

  Widget _buildPrayer(
      String name,
      DateTime time,
      IconData icon,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: const Color(0xFF176B5B),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),

          Text(
            _formatTime(time),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'مواقيت الصلاة',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          _buildPrayer(
            'الفجر',
            prayerTimes.fajr,
            Icons.wb_twilight,
          ),

          _buildPrayer(
            'الشروق',
            prayerTimes.sunrise,
            Icons.wb_sunny_outlined,
          ),

          _buildPrayer(
            'الظهر',
            prayerTimes.dhuhr,
            Icons.wb_sunny,
          ),

          _buildPrayer(
            'العصر',
            prayerTimes.asr,
            Icons.sunny_snowing,
          ),

          _buildPrayer(
            'المغرب',
            prayerTimes.maghrib,
            Icons.wb_twilight,
          ),

          _buildPrayer(
            'العشاء',
            prayerTimes.isha,
            Icons.nightlight_round,
          ),
        ],
      ),
    );
  }
}