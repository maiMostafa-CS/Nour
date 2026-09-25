import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AzkarZikrCard extends StatelessWidget {
  const AzkarZikrCard({
    super.key,
    required this.text,
    required this.count,
    required this.remaining,
    required this.progress,
    required this.onTap,
  });

  final String text;
  final int count;
  final int remaining;
  final double progress;
  final VoidCallback onTap;

  static const Color _primaryColor = Color(0xFF1B4332);
  static const Color _accentColor = Color(0xFFD4AF37);
  static const Color _cardColor = Color(0xFFFFFDF9);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.08),
              blurRadius: 15.r,
              offset: Offset(0, 5.h),
            ),
          ],
          border: Border.all(color: _accentColor.withOpacity(0.4), width: 1.5.w),
        ),
        child: Column(
          children: [
            Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                children: [
                  Text(
                    text,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: 22.sp,
                      height: 2.2,
                      color: const Color(0xFF2C2C2C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: _accentColor.withOpacity(0.5),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Icon(
                          Icons.star,
                          size: 16.r,
                          color: _accentColor,
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: _accentColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  if (count > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 50.r,
                          height: 50.r,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[200],
                                color: _primaryColor,
                                strokeWidth: 5.w,
                              ),
                              Center(
                                child: Text(
                                  '$remaining',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          'المتبقي',
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: _primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'اضغط للقراءة',
                        style: GoogleFonts.cairo(
                          color: _primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
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