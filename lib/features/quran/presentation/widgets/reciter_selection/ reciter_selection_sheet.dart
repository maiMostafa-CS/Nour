import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../domain/entities/quran_reciter.dart';

class ReciterSelectionSheet extends StatelessWidget {
  final List<QuranReciter> reciters;
  final QuranReciter? selectedReciter;
  final ValueChanged<QuranReciter> onSelected;

  const ReciterSelectionSheet({
    super.key,
    required this.reciters,
    required this.selectedReciter,
    required this.onSelected,
  });

  static const Color backgroundColor = Color(0xFFFCF5D7);
  static const Color primaryColor = Color(0xFF8B5A2B);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.vertical(
      top: Radius.circular(24.r),
    );

    return SafeArea(
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Material(
          color: backgroundColor,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * .75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12.h),

// ====================================================
// Handle
// ====================================================

                Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),

                SizedBox(height: 14.h),

// ====================================================
// العنوان
// ====================================================

                Text(
                  'اختر القارئ',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),

                SizedBox(height: 8.h),

// ====================================================
// قائمة القراء
// ====================================================

                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    itemCount: reciters.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1.h,
                      color: primaryColor.withOpacity(.12),
                    ),
                    itemBuilder: (context, index) {
                      final reciter = reciters[index];

                      final isSelected =
                          selectedReciter?.identifier == reciter.identifier;

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                        ),

// ==================================================
// صورة القارئ
// ==================================================

                        leading: CircleAvatar(
                          radius: 20.r,
                          backgroundColor: isSelected
                              ? primaryColor
                              : primaryColor.withOpacity(.12),
                          child: Icon(
                            Icons.person,
                            size: 20.sp,
                            color: isSelected ? Colors.white : primaryColor,
                          ),
                        ),

// ==================================================
// اسم القارئ
// ==================================================

                        title: Text(
                          reciter.name,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: const Color(0xFF333333),
                          ),
                        ),

// ==================================================
// الاسم الإنجليزي
// ==================================================

                        subtitle: Text(
                          reciter.englishName,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.black54,
                          ),
                        ),

// ==================================================
// علامة الاختيار
// ==================================================

                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: primaryColor,
                              )
                            : null,

// ==================================================
// اختيار القارئ
// ==================================================

                        onTap: () {
                          onSelected(reciter);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
