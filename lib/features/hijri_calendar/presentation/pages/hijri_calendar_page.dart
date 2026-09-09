import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        title: const Text(
          'التقويم الهجري',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: BlocBuilder<
          HijriCalendarBloc,
          HijriCalendarState>(
        builder: (context, state) {
          if (state is HijriCalendarLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is HijriCalendarError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
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
            padding: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              30,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      HijriCalendarHeader(
                        monthName: monthName,
                        year: state.year,
                        onPrevious: () {
                          context
                              .read<
                              HijriCalendarBloc>()
                              .add(
                            const PreviousHijriMonth(),
                          );
                        },
                        onNext: () {
                          context
                              .read<
                              HijriCalendarBloc>()
                              .add(
                            const NextHijriMonth(),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      const HijriWeekDays(),

                      const SizedBox(height: 10),

                      HijriCalendarGrid(
                        dates: state.dates,
                        selectedDate:
                        state.selectedDate,
                        onDateSelected: (date) {
                          context
                              .read<
                              HijriCalendarBloc>()
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

                const SizedBox(height: 20),

                if (state.selectedDate != null)
                  Align(
                    alignment:
                    Alignment.centerRight,
                    child: Text(
                      '${state.selectedDate!.day} '
                          '${state.selectedDate!.monthName} '
                          '${state.selectedDate!.year} هـ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                if (state.prayerTimes != null)
                  PrayerTimesCard(
                    prayerTimes:
                    state.prayerTimes!,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}