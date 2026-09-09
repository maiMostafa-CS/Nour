import 'package:flutter/material.dart';

import '../../domain/entities/hijri_date_entity.dart';

class HijriCalendarGrid extends StatelessWidget {
  final List<HijriDateEntity> dates;
  final HijriDateEntity? selectedDate;

  final ValueChanged<HijriDateEntity> onDateSelected;

  const HijriCalendarGrid({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (dates.isEmpty) {
      return const Center(
        child: Text('لا توجد بيانات'),
      );
    }

    final firstDate = dates.first.gregorianDate;

    final firstWeekday = firstDate.weekday % 7;

    final totalItems = firstWeekday + dates.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalItems,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        if (index < firstWeekday) {
          return const SizedBox();
        }

        final date = dates[index - firstWeekday];

        final isSelected =
            selectedDate?.gregorianDate.year ==
                date.gregorianDate.year &&
                selectedDate?.gregorianDate.month ==
                    date.gregorianDate.month &&
                selectedDate?.gregorianDate.day ==
                    date.gregorianDate.day;

        return GestureDetector(
          onTap: () => onDateSelected(date),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF176B5B)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: date.isToday
                  ? Border.all(
                color: const Color(0xFF176B5B),
                width: 1.5,
              )
                  : null,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: date.isToday ||
                      isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}