import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'minute_button.dart';

class IqamaTimeTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final int minutes;
  final ValueChanged<int> onChanged;

  const IqamaTimeTile({
    required this.name,
    required this.icon,
    required this.minutes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16.r),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 12.h,
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8CE),
                  borderRadius:
                  BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF176B5B),
                  size: 24.sp,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'بعد الأذان بـ $minutes دقيقة',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color:
                        Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              MinuteButton(
                icon: Icons.remove,
                onPressed: minutes > 1
                    ? () {
                  onChanged(minutes - 1);
                }
                    : null,
              ),

              SizedBox(width: 8.w),

              Container(
                width: 46.w,
                alignment: Alignment.center,
                child: Text(
                  '$minutes',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF176B5B),
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              MinuteButton(
                icon: Icons.add,
                onPressed: minutes < 60
                    ? () {
                  onChanged(minutes + 1);
                }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
