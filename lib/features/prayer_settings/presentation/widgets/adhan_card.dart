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
      appBar: AppBar(title:  Text(
        'اختيار المؤذن ',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF176B5B),
        ),
      ),
        centerTitle: true,
      ),
      body:
      Center(
        child: Column(children: [
          SizedBox(height: 26.h),
          SettingsCard(
            icon: Icons.record_voice_over_outlined,
            title: 'مؤذن الفجر',
            subtitle: 'اختيار مؤذن صلاة الفجر',
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
            title: 'مؤذن الظهر',
            subtitle: 'اختيار مؤذن صلاة الظهر',
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
            title: 'مؤذن العصر',
            subtitle: 'اختيار مؤذن صلاة العصر',
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
            title: 'مؤذن المغرب',
            subtitle: 'اختيار مؤذن صلاة المغرب',
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
            title: 'مؤذن العشاء',
            subtitle: 'اختيار مؤذن صلاة العشاء',
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.adhan,
                arguments: 'isha',
              );
            },
          ),

          SizedBox(height: 14.h),    ],),
      ),
    );
  }
}
