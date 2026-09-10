import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/hijri_calendar_bloc.dart';
import '../bloc/hijri_calendar_event.dart';
import '../bloc/hijri_calendar_state.dart';
import '../widgets/hijri_calendar_header.dart';
import '../widgets/hijri_week_days.dart';
import '../widgets/hijri_calendar_grid.dart';
import '../widgets/prayer_times_card.dart';

class HijriCalendarPage extends StatelessWidget {
  const HijriCalendarPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EA),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'التقويم الهجري',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: BlocBuilder<HijriCalendarBloc, HijriCalendarState>(
        builder: (context, state) {
          if (state is HijriCalendarLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is HijriCalendarError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
              ),
            );
          }

          if (state is! HijriCalendarLoaded) {
            return const SizedBox();
          }

          final monthName = state.dates.isNotEmpty
              ? state.dates.first.monthName
              : '';

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16.w,
              10.h,
              16.w,
              30.h,
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      HijriCalendarHeader(
                        monthName: monthName,
                        year: state.year,
                        onPrevious: () {
                          context
                              .read<HijriCalendarBloc>()
                              .add(
                            const PreviousHijriMonth(),
                          );
                        },
                        onNext: () {
                          context
                              .read<HijriCalendarBloc>()
                              .add(
                            const NextHijriMonth(),
                          );
                        },
                      ),

                      SizedBox(height: 20.h),

                      const HijriWeekDays(),

                      SizedBox(height: 10.h),

                      HijriCalendarGrid(
                        dates: state.dates,
                        selectedDate: state.selectedDate,
                        onDateSelected: (date) {
                          context
                              .read<HijriCalendarBloc>()
                              .add(
                            SelectHijriDate(
                              date.gregorianDate,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                if (state.selectedDate != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${state.selectedDate!.day} '
                          '${state.selectedDate!.monthName} '
                          '${state.selectedDate!.year} هـ',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                SizedBox(height: 12.h),

                if (state.prayerTimes != null)
                  PrayerTimesCard(
                    prayerTimes: state.prayerTimes!,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}