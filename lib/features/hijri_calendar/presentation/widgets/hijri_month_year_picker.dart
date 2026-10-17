import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HijriMonthYearPickerSheet extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final void Function(int year, int month) onSelected;

  const HijriMonthYearPickerSheet({
    super.key,
    required this.initialYear,
    required this.initialMonth,
    required this.onSelected,
  });

  static const List<String> hijriMonthNames = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  static Future<void> show(
    BuildContext context, {
    required int currentYear,
    required int currentMonth,
    required void Function(int year, int month) onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HijriMonthYearPickerSheet(
        initialYear: currentYear,
        initialMonth: currentMonth,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<HijriMonthYearPickerSheet> createState() =>
      _HijriMonthYearPickerSheetState();
}

class _HijriMonthYearPickerSheetState extends State<HijriMonthYearPickerSheet> {
  late int _selectedYear;
  late int _selectedMonth;
  late ScrollController _yearScrollController;

  static const int minYear = 1430;
  static const int maxYear = 1470;
  static const Color primaryColor = Color(0xFF176B5B);

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    _selectedMonth = widget.initialMonth;

    // Scroll roughly to selected year
    final index = (_selectedYear - minYear).clamp(0, maxYear - minYear);
    final initialOffset = (index * 85.0) - 120.0;
    _yearScrollController = ScrollController(
      initialScrollOffset: initialOffset > 0 ? initialOffset : 0,
    );
  }

  @override
  void dispose() {
    _yearScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 30.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'اختيار الشهر والسنة الهجرية',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                color: Colors.grey.shade600,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Years Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السنة الهجرية ($_selectedYear هـ)',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded, size: 22.sp),
                    onPressed: () {
                      if (_selectedYear > minYear) {
                        setState(() => _selectedYear--);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_left_rounded, size: 22.sp),
                    onPressed: () {
                      if (_selectedYear < maxYear) {
                        setState(() => _selectedYear++);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),

          // Horizontal Years Selector
          SizedBox(
            height: 44.h,
            child: ListView.builder(
              controller: _yearScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: (maxYear - minYear) + 1,
              itemBuilder: (context, i) {
                final year = minYear + i;
                final isSelected = year == _selectedYear;
                return Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: ChoiceChip(
                    label: Text(
                      '$year هـ',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: primaryColor,
                    backgroundColor: const Color(0xFFF7F3EA),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedYear = year;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 20.h),

          // Months Label
          Text(
            'أشهر السنة ($_selectedYear هـ)',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),

          // 12 Months Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
            ),
            itemBuilder: (context, i) {
              final monthNumber = i + 1;
              final monthName = HijriMonthYearPickerSheet.hijriMonthNames[i];
              final isSelected = monthNumber == _selectedMonth;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedMonth = monthNumber;
                  });
                  widget.onSelected(_selectedYear, _selectedMonth);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : const Color(0xFFF7F3EA),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$monthNumber. ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        monthName,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
