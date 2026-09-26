import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/services/unlock_card.dart';
import '../../../../core/theme/app_colors.dart';
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
              extendBodyBehindAppBar: false,
              backgroundColor: AppColors.creamBg,
              appBar: _buildAppBar(),
              body: SafeArea(
                top: false,
                child: _buildBody(context, state),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // AppBar
  // ═══════════════════════════════════════════════════════════
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.emeraldGreen,
              AppColors.deepGreen,
            ],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24.r),
            bottomRight: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepGreen.withOpacity(0.25),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mosque_rounded,
            color: AppColors.softGold,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            getCurrentHijriDate(),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Body
  // ═══════════════════════════════════════════════════════════
  Widget _buildBody(BuildContext context, HomeState state) {
    // ─── Loading ───
    if (state.loading && state.prayerTimes == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.emeraldGreen,
        ),
      );
    }

    // ─── Error ───
    if (state.errorMessage != null && state.prayerTimes == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48.sp,
                color: AppColors.emeraldGreen.withOpacity(0.4),
              ),
              SizedBox(height: 12.h),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.mediumText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final prayerTimes = state.prayerTimes;

    // ─── No prayer times ───
    if (prayerTimes == null) {
      return Center(
        child: Text(
          'جاري التحميل...',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.mediumText,
          ),
        ),
      );
    }

    // ─── Content ───
    return Column(
      children: [
        if (state.scheduling)
          const LinearProgressIndicator(
            minHeight: 2,
            color: AppColors.softGold,
            backgroundColor: Colors.transparent,
          ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),

                // ─── Top Bar: المدينة + زرار الموقع ───
                _buildTopBar(context, state),

                SizedBox(height: 14.h),

                // ─── كارت الصلاة القادمة ───
                NextPrayerCard(
                  prayerTimes: prayerTimes,
                  timezoneName: state.timezone,
                ),

                SizedBox(height: 22.h),

                _buildSectionTitle('مواقيت الصلاة'),
                SizedBox(height: 12.h),
                PrayerTimesWidget(
                  prayerTimes: prayerTimes,
                  timezoneName: state.timezone,
                ),

                SizedBox(height: 22.h),

                // ─── Grid الميزات ───
                BuildMainGrid(),

                SizedBox(height: 14.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Top Bar (المدينة + زرار الموقع)
  // ═══════════════════════════════════════════════════════════
  Widget _buildTopBar(BuildContext context, HomeState state) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepGreen.withOpacity(0.06),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.emeraldGreen.withOpacity(0.15),
                  AppColors.emeraldGreen.withOpacity(0.05),
                ],
              ),
            ),
            child:
            const CurrentLocationButton(),
          ),

          SizedBox(width: 8.w),

          // اسم المدينة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'الموقع الحالي',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.lightText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  state.cityName.trim().isEmpty
                      ? 'غير محدد'
                      : state.cityName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Section Title
  // ═══════════════════════════════════════════════════════════
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        // خط ذهبي رفيع
        Container(
          width: 4.w,
          height: 22.h,
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Helper: UnlockCard (اتركه زي ما هو)
// ═══════════════════════════════════════════════════════════
Future<void> enableUnlockCard(BuildContext context) async {
  void say(String m) {
    debugPrint('UnlockCard: $m');
    final sm = ScaffoldMessenger.of(context);
    sm.clearSnackBars();
    sm.showSnackBar(SnackBar(content: Text(m)));
  }

  try {
    say('1) الزرار اشتغل');

    final notif = await Permission.notification.request();
    say('2) صلاحية الإشعارات: $notif');

    final has = await UnlockCard.hasOverlayPermission();
    say('3) صلاحية الظهور فوق التطبيقات = $has');

    if (!has) {
      await UnlockCard.requestOverlayPermission();
      say('4) فتحت صفحة الإعدادات، فعّلها وارجع دوس تاني');
      return;
    }

    await UnlockCard.start();
    say('5) startService اتنادى بنجاح');
  } catch (e, s) {
    debugPrint('UnlockCard ERROR: $e\n$s');
    say('خطأ: $e');
  }
}