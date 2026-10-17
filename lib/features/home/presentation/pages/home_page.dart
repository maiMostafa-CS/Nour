import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/unlock_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../locations/presentation/bloc/bloc.dart';
import '../../../locations/presentation/bloc/blocEvent.dart';
import '../../../locations/presentation/bloc/blocState.dart';
import '../../../locations/presentation/widgets/current_location_dialog.dart';
import '../../../locations/presentation/widgets/current_location_helper.dart';
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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('📱 App resumed → checking location change...');
      context.read<HomeBloc>().add(const CheckLocationIfChanged());
    }
  }

  Future<void> _requestLocationUpdate(BuildContext context) async {
    final shouldUpdate = await showCurrentLocationDialog(context);
    if (!shouldUpdate || !context.mounted) return;

    final hasPermission =
        await CurrentLocationHelper.checkAndRequestPermission(context);
    if (!hasPermission || !context.mounted) return;

    context.read<LocationBloc>().add(
      const GetCurrentLocation(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationBloc, LocationState>(
      listener: (context, locationState) {
        final location = locationState.currentLocation;

        if (locationState.status == LocationStatus.loading) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'locating_gps'.tr(),
                    style: TextStyle(fontSize: 13.sp),
                  ),
                ],
              ),
              backgroundColor: AppColors.deepGreen,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        } else if (locationState.status == LocationStatus.success &&
            location != null) {
          context.read<HomeBloc>().add(
            HomeLocationChanged(location),
          );

          final cityName = location.city.trim().isNotEmpty
              ? location.city.trim()
              : 'current_location'.tr();

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'location_updated_success'.tr(args: [cityName]),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.emeraldGreen,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        } else if (locationState.status == LocationStatus.failure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      locationState.errorMessage ?? 'location_update_failed'.tr(),
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        }
      },
      child: BlocListener<HomeBloc, HomeState>(
        listenWhen: (previous, current) =>
            current.autoUpdateMessage != null &&
            current.autoUpdateMessage != previous.autoUpdateMessage,
        listener: (context, homeState) {
          if (homeState.autoUpdateMessage != null) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        homeState.autoUpdateMessage!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.deepGreen,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
            context.read<HomeBloc>().add(const ClearAutoUpdateMessage());
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Scaffold(
              extendBodyBehindAppBar: false,
              backgroundColor: AppColors.creamBg,
              appBar: _buildAppBar(context),
              body: SafeArea(
                top: false,
                child: _buildBody(context, state),
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // AppBar
  // ═══════════════════════════════════════════════════════════
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      titleSpacing: 0,
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: InkWell(
            onTap: () {
              if (context.locale.languageCode == 'ar') {
                context.setLocale(const Locale('en'));
              } else {
                context.setLocale(const Locale('ar'));
              }
            },
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.softGold.withOpacity(0.6),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.language_rounded,
                    color: AppColors.softGold,
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    context.locale.languageCode == 'ar' ? 'EN' : 'عربي',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mosque_rounded,
                color: AppColors.softGold,
                size: 20.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                getCurrentHijriDate(context),
                maxLines: 1,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
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
          'loading'.tr(),
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
                _buildTopBar(context, state),
                SizedBox(height: 14.h),
                NextPrayerCard(
                  prayerTimes: prayerTimes,
                  timezoneName: state.timezone,
                ),

                SizedBox(height: 22.h),

                _buildSectionTitle('prayer_times'.tr()),
                SizedBox(height: 12.h),
                PrayerTimesWidget(
                  prayerTimes: prayerTimes,
                  timezoneName: state.timezone,
                ),

                SizedBox(height: 22.h),

                // ─── Feature grid ───
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
  // Top Bar (city + location button)
  // ═══════════════════════════════════════════════════════════
  Widget _buildTopBar(BuildContext context, HomeState state) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, locationState) {
        final isLocating = locationState.status == LocationStatus.loading;
        final isUpdating = isLocating || state.loading;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isUpdating
                ? null
                : () => _requestLocationUpdate(context),
            borderRadius: BorderRadius.circular(16.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isUpdating
                      ? AppColors.emeraldGreen.withOpacity(0.5)
                      : AppColors.gold.withOpacity(0.20),
                  width: isUpdating ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUpdating
                        ? AppColors.emeraldGreen.withOpacity(0.12)
                        : AppColors.deepGreen.withOpacity(0.06),
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
                    child: isUpdating
                        ? Center(
                            child: SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.emeraldGreen,
                              ),
                            ),
                          )
                        : const CurrentLocationButton(),
                  ),

                  SizedBox(width: 8.w),

                  // City name & status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isUpdating ? 'updating_location'.tr() : 'current_location'.tr(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: isUpdating
                                ? AppColors.emeraldGreen
                                : AppColors.lightText,
                            fontWeight: isUpdating
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            isUpdating
                                ? 'locating_position'.tr()
                                : (state.cityName.trim().isEmpty
                                    ? 'not_specified'.tr()
                                    : state.cityName),
                            key: ValueKey<String>(
                              isUpdating ? 'loading' : state.cityName,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: isUpdating
                                  ? AppColors.emeraldGreen
                                  : AppColors.darkText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Refresh indicator / icon on the side
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: isUpdating
                          ? AppColors.emeraldGreen.withOpacity(0.08)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 16.sp,
                      color: isUpdating
                          ? AppColors.emeraldGreen
                          : AppColors.mediumText.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Section Title
  // ═══════════════════════════════════════════════════════════
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        // Thin gold line
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