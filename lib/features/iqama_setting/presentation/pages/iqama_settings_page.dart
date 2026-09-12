import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/iqama_settings_bloc.dart';
import '../bloc/iqama_settings_event.dart';
import '../bloc/iqama_settings_state.dart';
import '../widgets/iqama_time.dart';

class IqamaSettingsPage extends StatelessWidget {
  const IqamaSettingsPage({
    super.key,
  });

  static const Color primaryColor =
  Color(0xFF176B5B);

  static const Color backgroundColor =
  Color(0xFFF7F3EA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'إعدادات الإقامة',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: BlocBuilder<
          IqamaSettingsBloc,
          IqamaSettingsState>(
        builder: (context, state) {
          if (state.status ==
              IqamaSettingsStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              Container(
                margin: EdgeInsets.only(
                  bottom: 18.h,
                ),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8CE),
                  borderRadius:
                  BorderRadius.circular(18.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46.w,
                      height: 46.w,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius:
                        BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        Icons.access_time_rounded,
                        color: Colors.white,
                        size: 25.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'وقت الإقامة',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'حدد مدة الانتظار بعد الأذان لكل صلاة',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color:
                              Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              IqamaTimeTile(
                name: 'الفجر',
                icon: Icons.nightlight_round,
                minutes: state.settings.fajr,
                onChanged: (value) {
                  _update(
                    context,
                    prayerIndex: 0,
                    minutes: value,
                  );
                },
              ),

              IqamaTimeTile(
                name: 'الشروق',
                icon: Icons.wb_sunny_outlined,
                minutes: state.settings.sunrise,
                onChanged: (value) {
                  _update(
                    context,
                    prayerIndex: 1,
                    minutes: value,
                  );
                },
              ),

              IqamaTimeTile(
                name: 'الظهر',
                icon: Icons.wb_sunny,
                minutes: state.settings.dhuhr,
                onChanged: (value) {
                  _update(
                    context,
                    prayerIndex: 2,
                    minutes: value,
                  );
                },
              ),

              IqamaTimeTile(
                name: 'العصر',
                icon: Icons.wb_twilight,
                minutes: state.settings.asr,
                onChanged: (value) {
                  _update(
                    context,
                    prayerIndex: 3,
                    minutes: value,
                  );
                },
              ),

              IqamaTimeTile(
                name: 'المغرب',
                icon: Icons.wb_twilight,
                minutes: state.settings.maghrib,
                onChanged: (value) {
                  _update(
                    context,
                    prayerIndex: 4,
                    minutes: value,
                  );
                },
              ),

              IqamaTimeTile(
                name: 'العشاء',
                icon: Icons.nights_stay_outlined,
                minutes: state.settings.isha,
                onChanged: (value) {
                  _update(
                    context,
                    prayerIndex: 5,
                    minutes: value,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _update(
      BuildContext context, {
        required int prayerIndex,
        required int minutes,
      }) {
    context.read<IqamaSettingsBloc>().add(
      UpdateIqamaSettingEvent(
        prayerIndex: prayerIndex,
        minutes: minutes,
      ),
    );
  }
}
