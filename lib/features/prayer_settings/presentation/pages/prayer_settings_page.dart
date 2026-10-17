import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/unlock_card.dart';
import '../../../home/presentation/bloc/bloc.dart';
import '../../../home/presentation/bloc/home_state.dart';
import '../widgets/adhan_card.dart';
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
          'settings'.tr(),
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
          child: ListView(
            children: [
              SettingsCard(
                icon: Icons.notifications_active_outlined,
                title: 'adhan_settings'.tr(),
                subtitle: 'adhan_settings_subtitle'.tr(),
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
                title: 'iqama_time'.tr(),
                subtitle: 'iqama_time_subtitle'.tr(),
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
                title: 'muezzin_voice'.tr(),
                subtitle: 'muezzin_voice_subtitle'.tr(),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdhanCard(),
                    ),
                  );
                },
              ),
              SizedBox(height: 14.h),
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  return SettingsCard(
                    icon: Icons.location_on_outlined,
                    title: 'location'.tr(),
                    subtitle: state.cityName.isEmpty ? 'not_specified'.tr() : state.cityName,
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
                icon: Icons.language_rounded,
                title: 'language'.tr(),
                subtitle: context.locale.languageCode == 'ar' ? 'العربية' : 'English',
                onTap: () {
                  if (context.locale.languageCode == 'ar') {
                    context.setLocale(const Locale('en'));
                  } else {
                    context.setLocale(const Locale('ar'));
                  }
                },
              ),
              SizedBox(height: 14.h),
              SettingsCard(
                icon: Icons.lock_clock_outlined,
                title: 'enable_khatma'.tr(),
                subtitle: 'ayah_on_unlock'.tr(),
                trailing: const UnlockAyahSwitch(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
