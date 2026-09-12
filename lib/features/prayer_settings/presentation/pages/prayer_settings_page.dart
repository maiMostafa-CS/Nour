import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/router/app_router.dart';


class PrayerSettingsPage extends StatelessWidget {
  const PrayerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EA),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F3EA),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'إعدادات الصلاة',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF176B5B),
          ),
        ),
      ),

      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          child: Column(
            children: [
              _SettingsCard(
                icon: Icons.notifications_active_outlined,
                title: 'إعدادات الأذان',
                subtitle: 'تشغيل أو إيقاف الأذان لكل صلاة',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.adhanSetting,
                  );
                },
              ),

              SizedBox(height: 14.h),

              _SettingsCard(
                icon: Icons.mosque_outlined,
                title: 'وقت الإقامة',
                subtitle: 'تحديد عدد الدقائق بعد كل صلاة',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.iqamaSettings,
                  );
                },
              ),

              SizedBox(height: 14.h),

              _SettingsCard(
                icon: Icons.record_voice_over_outlined,
                title: 'صوت المؤذن',
                subtitle: 'اختيار المؤذن المفضل لديك',
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    AppRouter.adhan,

                  );
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 18.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8CE),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(
                  icon,
                  size: 27.sp,
                  color: const Color(0xFF176B5B),
                ),
              ),

              SizedBox(width: 14.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF176B5B),
                      ),
                    ),

                    SizedBox(height: 5.h),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17.sp,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}