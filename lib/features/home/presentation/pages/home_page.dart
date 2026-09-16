import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/scheduler/adhan_scheduler.dart';
import '../../../locations/presentation/bloc/bloc.dart';
import '../../../locations/presentation/bloc/blocState.dart';
import '../../../prayer_times/presentation/widgets/prayer_times_widget.dart';
import '../bloc/bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widget/next_prayer_card.dart';
import '../widget/build_mainGrid.dart';
import '../widget/current_location_button.dart';
import '../widget/getCurrentHijriDate.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedNavIndex = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationBloc, LocationState>(
      listener: (context, locationState) {
        final location = locationState.currentLocation;

        if (locationState.status == LocationStatus.success &&
            location != null) {
          context.read<HomeBloc>().add(
                HomeLocationChanged(location),
              );
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Directionality(
            textDirection: widgets.TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                backgroundColor: const Color(0xFFE8E8CE),
                elevation: 0,
                title: Text(
                  getCurrentHijriDate(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF222222),
                  ),
                ),
              ),
              backgroundColor: const Color(0xFFE8E8CE),
              body: SafeArea(
                child: _buildBody(context, state),
              ),

            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    if (state.loading && state.prayerTimes == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null && state.prayerTimes == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            state.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      );
    }

    final prayerTimes = state.prayerTimes;

    if (prayerTimes == null) {
      return Center(
        child: Text(
          'جاري التحميل...',
          style: TextStyle(fontSize: 14.sp),
        ),
      );
    }

    return Column(
      children: [
        if (state.scheduling) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(context, state),
                SizedBox(height: 5.h),
                // ElevatedButton(
                //   onPressed: () async {
                //     final alarms = await Alarm.getAlarms();
                //
                //     debugPrint('════════════════════════════════════');
                //     debugPrint('📋 ALL ALARMS (${alarms.length})');
                //     debugPrint('════════════════════════════════════');
                //
                //     for (final alarm in alarms) {
                //       if (alarm.payload == 'adhan') {
                //         debugPrint('🕌 ADHAN');
                //         debugPrint('   id=${alarm.id}');
                //         debugPrint('   time=${alarm.dateTime}');
                //         debugPrint('   🎙️ asset=${alarm.assetAudioPath}');  // ← المهم
                //       }
                //     }
                //   },
                //   child: const Text('Print Adhan Alarms'),
                // ),
                NextPrayerCard(
                  prayerTimes: prayerTimes,
                  timezoneName: state.timezone,
                  cityName: state.cityName,
                ),
                SizedBox(height: 18.h),
                _buildSectionTitle('مواقيت الصلاة'),
                SizedBox(height: 10.h),
                PrayerTimesWidget(
                  prayerTimes: prayerTimes,
                  timezoneName: state.timezone,
                ),
                SizedBox(height: 18.h),
                BuildMainGrid(),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, HomeState state) {
    return Row(
      children: [
        const CurrentLocationButton(),
        Text(
          state.cityName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF222222),
          ),
        ),
      ],);
  }
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF222222),
      ),
    );
  }
}
