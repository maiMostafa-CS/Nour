import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/unlock_card.dart';
import '../../../home/presentation/bloc/bloc.dart';
import '../../../home/presentation/bloc/home_state.dart';
import '../widgets/setting_card.dart';

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
          'إعدادات ',
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
              SettingsCard(
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
              SettingsCard(
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
              SettingsCard(
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
              SizedBox(height: 14.h),
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  return SettingsCard(
                    icon: Icons.location_on_outlined,
                    title: 'الموقع',
                    subtitle: state.cityName,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.locationPage,
                      );
                    },
                  );
                },
              ),

              SizedBox(height: 14.h),

              SettingsCard(
                icon: Icons.record_voice_over_outlined,
                title: 'تفعيل الخاتمه ',
                subtitle: 'آية عند فتح الهاتف',
                trailing: UnlockAyahSwitch(),

              ),
            ],
          ),
        ),
      ),
    );
  }
}
