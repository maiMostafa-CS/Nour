import 'package:flutter/material.dart';

class HijriCalendarHeader extends StatelessWidget {
  final String monthName;
  final int year;

  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const HijriCalendarHeader({
    super.key,
    required this.monthName,
    required this.year,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onNext,
          icon: const Icon(
            Icons.chevron_left_rounded,
          ),
        ),

        Column(
          children: [
            Text(
              monthName,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$year هـ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),

        IconButton(
          onPressed: onPrevious,
          icon: const Icon(
            Icons.chevron_right_rounded,
          ),
        ),
      ],
    );
  }
}