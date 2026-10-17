import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/hijri_calendar_bloc.dart';
import '../bloc/hijri_calendar_event.dart';
import '../bloc/hijri_calendar_state.dart';
import '../widgets/hijri_calendar_header.dart';
import '../widgets/hijri_week_days.dart';
import '../widgets/hijri_calendar_grid.dart';
import '../widgets/hijri_month_year_picker.dart';
import '../widgets/prayer_times_card.dart';

class HijriCalendarPage extends StatefulWidget {
  const HijriCalendarPage({
    super.key,
  });

  @override
  State<HijriCalendarPage> createState() => _HijriCalendarPageState();
}

class _HijriCalendarPageState extends State<HijriCalendarPage> {
  static const String _timezoneKey = 'prayer_location_timezone';
  String _timezoneName = 'Africa/Cairo';

  @override
  void initState() {
    super.initState();
    _loadTimezone();
  }

  Future<void> _loadTimezone() async {
    final prefs = await SharedPreferences.getInstance();
    final timezone = prefs.getString(_timezoneKey);

    if (!mounted || timezone == null || timezone.isEmpty) {
      return;
    }

    setState(() {
      _timezoneName = timezone;
    });
  }

  void _openMonthYearPicker(BuildContext context, int year, int month) {
    HijriMonthYearPickerSheet.show(
      context,
      currentYear: year,
      currentMonth: month,
      onSelected: (selectedYear, selectedMonth) {
        context.read<HijriCalendarBloc>().add(
              SetHijriMonthAndYear(
                year: selectedYear,
                month: selectedMonth,
              ),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EA),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'hijri_calendar'.tr(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BlocBuilder<HijriCalendarBloc, HijriCalendarState>(
            builder: (context, state) {
              if (state is! HijriCalendarLoaded) return const SizedBox();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      context
                          .read<HijriCalendarBloc>()
                          .add(const LoadHijriCalendar());
                    },
                    icon: Icon(
                      Icons.today_rounded,
                      size: 18.sp,
                      color: const Color(0xFF176B5B),
                    ),
                    label: Text(
                      'today'.tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF176B5B),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.calendar_month_rounded,
                      size: 22.sp,
                      color: const Color(0xFF176B5B),
                    ),
                    tooltip: 'choose_month_and_year'.tr(),
                    onPressed: () => _openMonthYearPicker(
                      context,
                      state.year,
                      state.month,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
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

          final monthName = 'hijri_month_${state.month}'.tr();
          final hijriSuffix = 'hijri_suffix'.tr();

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
                        onTitleTap: () => _openMonthYearPicker(
                          context,
                          state.year,
                          state.month,
                        ),
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
                          '${'hijri_month_${state.selectedDate!.month}'.tr()} '
                          '${state.selectedDate!.year} $hijriSuffix',
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
                    timezoneName: _timezoneName,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}