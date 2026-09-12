import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../locations/presentation/widgets/ErrorView.dart';
import '../../domain/entities/adhan_settings_entity.dart';
import '../bloc/adhan_settings_bloc.dart';
import '../bloc/adhan_settings_event.dart';
import '../bloc/adhan_settings_state.dart';
import '../widgets/infoCard.dart';
import '../widgets/prayer_switch_tile.dart';

class AdhanSettingsPage extends StatelessWidget {
  const AdhanSettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F3EA),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Color(0xFF176B5B),
        ),
        title: Text(
          'أوقات الأذان',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF176B5B),
          ),
        ),
      ),
      body: BlocBuilder<AdhanSettingsBloc, AdhanSettingsState>(
        builder: (context, state) {
          if (state.status == AdhanSettingsStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF176B5B),
              ),
            );
          }

          if (state.status == AdhanSettingsStatus.error &&
              state.settings == const AdhanSettingsEntity(
                fajr: true,
                sunrise: false,
                dhuhr: true,
                asr: true,
                maghrib: true,
                isha: true,
              )) {
            return ErrorView(
              message: state.errorMessage ?? 'حدث خطأ، حاول مرة أخرى',
              onRetry: () {
                context.read<AdhanSettingsBloc>().add(
                  const LoadAdhanSettings(),
                );
              },
            );
          }

          final settings = state.settings;

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            children: [
              InfoCard(),

              SizedBox(height: 20.h),

              PrayerSwitchTile(
                name: 'الفجر',
                icon: Icons.nightlight_outlined,
                enabled: settings.fajr,
                onChanged: (value) {
                  _toggle(
                    context,
                    index: 0,
                    value: value,
                  );
                },
              ),

              PrayerSwitchTile(
                name: 'الشروق',
                icon: Icons.wb_sunny_outlined,
                enabled: settings.sunrise,
                onChanged: (value) {
                  _toggle(
                    context,
                    index: 1,
                    value: value,
                  );
                },
              ),

              PrayerSwitchTile(
                name: 'الظهر',
                icon: Icons.wb_sunny,
                enabled: settings.dhuhr,
                onChanged: (value) {
                  _toggle(
                    context,
                    index: 2,
                    value: value,
                  );
                },
              ),

              PrayerSwitchTile(
                name: 'العصر',
                icon: Icons.wb_twilight_outlined,
                enabled: settings.asr,
                onChanged: (value) {
                  _toggle(
                    context,
                    index: 3,
                    value: value,
                  );
                },
              ),

              PrayerSwitchTile(
                name: 'المغرب',
                icon: Icons.wb_twilight,
                enabled: settings.maghrib,
                onChanged: (value) {
                  _toggle(
                    context,
                    index: 4,
                    value: value,
                  );
                },
              ),

              PrayerSwitchTile(
                name: 'العشاء',
                icon: Icons.nights_stay_outlined,
                enabled: settings.isha,
                onChanged: (value) {
                  _toggle(
                    context,
                    index: 5,
                    value: value,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggle(
      BuildContext context, {
        required int index,
        required bool value,
      }) {
    context.read<AdhanSettingsBloc>().add(
      ToggleAdhanSetting(
        prayerIndex: index,
        enabled: value,
      ),
    );
  }
}

