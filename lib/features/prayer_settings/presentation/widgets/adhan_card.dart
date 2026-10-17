import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/features/prayer_settings/presentation/widgets/setting_card.dart';

import '../../../../core/router/app_router.dart';

class AdhanCard extends StatefulWidget {
  const AdhanCard({super.key});

  @override
  State<AdhanCard> createState() => _AdhanCardState();
}

class _AdhanCardState extends State<AdhanCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'choose_muezzin'.tr(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF176B5B),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 26.h),
            SettingsCard(
              icon: Icons.record_voice_over_outlined,
              title: 'muezzin_fajr'.tr(),
              subtitle: 'choose_muezzin_fajr'.tr(),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.adhan,
                  arguments: 'fajr',
                );
              },
            ),

            SizedBox(height: 14.h),

            SettingsCard(
              icon: Icons.record_voice_over_outlined,
              title: 'muezzin_dhuhr'.tr(),
              subtitle: 'choose_muezzin_dhuhr'.tr(),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.adhan,
                  arguments: 'dhuhr',
                );
              },
            ),

            SizedBox(height: 14.h),

            SettingsCard(
              icon: Icons.record_voice_over_outlined,
              title: 'muezzin_asr'.tr(),
              subtitle: 'choose_muezzin_asr'.tr(),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.adhan,
                  arguments: 'asr',
                );
              },
            ),

            SizedBox(height: 14.h),

            SettingsCard(
              icon: Icons.record_voice_over_outlined,
              title: 'muezzin_maghrib'.tr(),
              subtitle: 'choose_muezzin_maghrib'.tr(),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.adhan,
                  arguments: 'maghrib',
                );
              },
            ),

            SizedBox(height: 14.h),

            SettingsCard(
              icon: Icons.record_voice_over_outlined,
              title: 'muezzin_isha'.tr(),
              subtitle: 'choose_muezzin_isha'.tr(),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.adhan,
                  arguments: 'isha',
                );
              },
            ),

            SizedBox(height: 14.h),
          ],
        ),
      ),
    );
  }
}
