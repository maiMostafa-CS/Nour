import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AzkarCategoryCard extends StatelessWidget {
  const AzkarCategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  static const Color _primaryColor = Color(0xFF1B4332);
  static const Color _accentColor = Color(0xFFD4AF37);
  static const Color _cardColor = Color(0xFFFFFDF9);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      color: _cardColor,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: _accentColor.withOpacity(0.3)),
      ),
      clipBehavior: Clip.antiAlias, // ✅ عشان الـ splash يبان جوه الحواف
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _primaryColor, size: 24.r),
        ),
        title: Text(
          title,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.amiri(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.r,
          color: _accentColor,
        ),
        onTap: onTap,
      ),
    );
  }
}