import 'package:flutter/material.dart';

class HijriWeekDays extends StatelessWidget {
  const HijriWeekDays({super.key});

  @override
  Widget build(BuildContext context) {
    const days = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];

    return Row(
      children: days
          .map(
            (day) => Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      )
          .toList(),
    );
  }
}