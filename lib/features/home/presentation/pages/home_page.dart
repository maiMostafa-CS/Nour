import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/adhan_scheduler_service.dart';
import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/adhan_scheduler_service.dart';
import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/config/prayer_scheduler_config.dart';
import '../../../../injection_container.dart';
import '../../../hijri_calendar/domain/usecases/get_hijri_date.dart';
import '../../../hijri_calendar/presentation/bloc/hijri_calendar_bloc.dart';
import '../../../locations/domain/entity/current_location_entity.dart';
import '../../../locations/domain/entity/location_entity.dart';
import '../../../locations/presentation/bloc/bloc.dart';
import '../../../locations/presentation/bloc/blocEvent.dart';
import '../../../locations/presentation/bloc/blocState.dart';
import '../../../locations/presentation/pages/locationPage.dart';
import '../../../locations/presentation/widgets/current_location_dialog.dart';
import '../../../prayer_times/presentation/bloc/prayer_bloc.dart';
import '../../../prayer_times/presentation/widgets/prayer_times_widget.dart';
import '../widget/buildBottomNavigation.dart';
import '../widget/buildDateLocation.dart';
import '../widget/build_mainGrid.dart';
import '../widget/getCurrentHijriDate.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> with RouteAware {
  Future<void> _handleCurrentLocationUpdate() async {
    final shouldUpdate =
    await showCurrentLocationDialog(context);

    if (!shouldUpdate) return;

    final ready =
    await CurrentLocationHelper.checkAndRequestPermission(
      context,
    );

    if (!ready) return;

    if (!mounted) return;

    context.read<LocationBloc>().add(
      const GetCurrentLocation(),
    );
  }
  Timer? _timer;

  String? cityName;

  int selectedNavIndex = 0;

  bool _adhanScheduled = false;

  double _latitude = 30.0444;
  double _longitude = 31.2357;

  bool _locationReady = false;

  static const String _locationModeKey = 'prayer_location_mode';
  static const String _locationModeAuto = 'auto';
  static const String _locationModeManual = 'manual';

  String _cityName = 'Select location';
  String _locationTimezone = 'Africa/Cairo';

  static const String _locationTimezoneKey = 'prayer_location_timezone';

  late final HijriCalendarBloc _hijriCalendarBloc;
  late final GetHijriDate _getHijriDate;
  late final PrayerBloc _prayerBloc;

  @override
  void dispose() {
    debugPrint(
      '💀💀💀 HOME PAGE DISPOSE: ${identityHashCode(this)}',
    );

    _timer?.cancel();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    debugPrint(
      '🏠🏠🏠 HOME PAGE INIT: ${identityHashCode(this)}',
    );

    _hijriCalendarBloc = sl<HijriCalendarBloc>();
    _prayerBloc = sl<PrayerBloc>();

    _loadLocationAndPrayerTimes();

    _getHijriDate = sl<GetHijriDate>();
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _prayerBloc,
      child: MultiBlocListener(
        listeners: [
          // =========================
          // Location Listener
          // =========================
          BlocListener<LocationBloc, LocationState>(
            listener: _onLocationStateChanged,
          ),

          // =========================
          // Prayer Listener
          // =========================
          BlocListener<PrayerBloc, PrayerState>(
            listener: (context, state) async {
              if (state is! PrayerLoaded) {
                return;
              }

              debugPrint(
                '🕌 PRAYER LOADED | '
                    'lat=$_latitude | '
                    'lng=$_longitude',
              );

              final service = AdhanSchedulerService();

              try {
                debugPrint('🔔 SCHEDULING ADHAN...');

                await service.showNextPrayerCountdown(
                  state.prayerTimes,
                );

                await service.schedulePrayerAdhan(
                  state.prayerTimes,
                  latitude:state.latitude,
                  longitude:  state.longitude,
                );

                _adhanScheduled = true;

                debugPrint(
                  '✅ ADHAN SCHEDULED SUCCESSFULLY',
                );
              } catch (e, stackTrace) {
                _adhanScheduled = false;

                debugPrint(
                  '❌ ADHAN SCHEDULING FAILED: $e',
                );

                debugPrint('$stackTrace');
              }
            },
          ),
        ],

        // =========================
        // Home UI
        // =========================
        child: Directionality(
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
              child: BlocBuilder<PrayerBloc, PrayerState>(
                builder: (context, state) {
                  if (state is PrayerLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is PrayerError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                        ),
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

                  if (state is PrayerLoaded) {
                    final prayerTimes = state.prayerTimes;

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics:
                            const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                _buildTopBar(),

                                // ElevatedButton(
                                //   onPressed: () {
                                //     AutoRenewTest.run();
                                //   },
                                //   child: const Text('data'),
                                // ),

                                SizedBox(height: 5.h),

                                NextPrayerCard(
                                  prayerTimes: prayerTimes,
                                  timezoneName: _locationTimezone,
                                ),

                                SizedBox(height: 18.h),

                                _buildSectionTitle(
                                  'مواقيت الصلاة',
                                ),

                                SizedBox(height: 10.h),

                                PrayerTimesWidget(
                                  prayerTimes: prayerTimes,
                                  timezoneName: _locationTimezone,
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

                  return Center(
                    child: Text(
                      'جاري التحميل...',
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                },
              ),
            ),

            bottomNavigationBar: SafeArea(
              top: false,
              child: CustomBottomNavigation(
                selectedIndex: selectedNavIndex,
                onSelected: (index) {
                  setState(() {
                    selectedNavIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: InkWell(
            onTap: _openLocationPage,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 6.h,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 25.sp,
                    color: const Color(0xFF222222),
                  ),

                  SizedBox(width: 5.w),

                  Flexible(
                    child: Text(
                      _cityName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF222222),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),),
        Row(children: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRouter.prayerSettingsPage,
              );
            },
            icon: Icon(
              Icons.settings,
              size: 25.sp,
              color: const Color(0xFF222222),
            ),
          ),

          IconButton(onPressed:_handleCurrentLocationUpdate,
              icon: Icon(Icons.location_on_outlined)),
        ],)
      ],
    );
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

  Future<void> _openLocationPage() async {
    final result = await Navigator.pushNamed(
      context,
      AppRouter.locationPage,
    );

    if (!mounted || result == null) {
      return;
    }

    if (result is! Map) {
      debugPrint(
        '❌ Invalid location result: ${result.runtimeType}',
      );
      return;
    }

    final location = result['location'];
    final type = result['type'];

    double lat;
    double lng;
    String timezoneName;

    // ============================================================
    // CURRENT GPS LOCATION
    // ============================================================

    if (location is CurrentLocationEntity) {
      lat = location.latitude;
      lng = location.longitude;
      cityName = location.city;
      timezoneName = location.timezone;

      debugPrint(
        '📍 CURRENT GPS | '
            'city=${location.city} | '
            'country=${location.country} | '
            'lat=$lat | '
            'lng=$lng',
      );

      debugPrint(
        '🏙️ GPS CITY = $cityName',
      );
    }

    // ============================================================
    // MANUAL LOCATION
    // ============================================================

    else if (location is LocationEntity) {
      lat = location.latitude;
      lng = location.longitude;
      timezoneName = location.timezone;

      cityName = location.city;

      debugPrint(
        '📍 MANUAL LOCATION FROM PAGE | '
            'city=${location.city} | '
            'country=${location.country} | '
            'lat=$lat | '
            'lng=$lng',
      );
    }

    // ============================================================
    // INVALID LOCATION
    // ============================================================

    else {
      debugPrint(
        '❌ Invalid location type: ${location.runtimeType}',
      );
      return;
    }

    final prefs =
    await SharedPreferences.getInstance();

    // ============================================================
    // SAVE LOCATION MODE
    // ============================================================

    await prefs.setString(
      'prayer_city_name',
      cityName ?? '',
    );

    if (timezoneName.isNotEmpty) {
      await prefs.setString(
        _locationTimezoneKey,
        timezoneName,
      );
    }

    if (type == LocationSelectionType.current) {
      await prefs.setString(
        _locationModeKey,
        _locationModeAuto,
      );

      debugPrint(
        '📍 HOME LOCATION MODE = AUTO',
      );
    } else {
      await prefs.setString(
        _locationModeKey,
        _locationModeManual,
      );

      await prefs.setDouble(
        'prayer_manual_latitude',
        lat,
      );

      await prefs.setDouble(
        'prayer_manual_longitude',
        lng,
      );

      debugPrint(
        '📍 HOME LOCATION MODE = MANUAL',
      );
    }

    // ============================================================
    // SAVE LAST COORDINATES
    // ============================================================

    await prefs.setDouble(
      prayerLastLatitudePrefsKey,
      lat,
    );

    await prefs.setDouble(
      prayerLastLongitudePrefsKey,
      lng,
    );

    if (!mounted) {
      return;
    }

    // ============================================================
    // UPDATE HOME LOCATION
    // ============================================================

    setState(() {
      _latitude = lat;
      _longitude = lng;
      _cityName = cityName ?? '';
      if (timezoneName.isNotEmpty) {
        _locationTimezone = timezoneName;
      }
      _locationReady = true;
      _adhanScheduled = false;
    });

    debugPrint(
      '🏠 HOME LOCATION UPDATED | '
          'lat=$_latitude | '
          'lng=$_longitude',
    );

    // ============================================================
    // CANCEL OLD ADHAN ALARMS
    // ============================================================

    try {
      await AdhanSchedulerService().cancelAdhans();

      debugPrint(
        '✅ OLD ADHAN ALARMS CANCELLED',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ CANCEL OLD ALARMS FAILED: $e',
      );

      debugPrint('$stackTrace');
    }

    // ============================================================
    // LOAD PRAYER TIMES FOR NEW LOCATION
    // ============================================================

    debugPrint(
      '🕌 LOAD NEW PRAYER TIMES | '
          'lat=$lat | '
          'lng=$lng',
    );

    _prayerBloc.add(
      LoadPrayerTimes(
        latitude: lat,
        longitude: lng,
        date: DateTime.now(),
      ),
    );
  }

  Future<void> _loadLocationAndPrayerTimes() async {
    final prefs =
    await SharedPreferences.getInstance();

    final savedCity =
    prefs.getString('prayer_city_name');

    final savedTimezone =
    prefs.getString(_locationTimezoneKey);

    if (savedTimezone != null && savedTimezone.isNotEmpty) {
      _locationTimezone = savedTimezone;
    }

    if (savedCity != null && mounted) {
      setState(() {
        _cityName = savedCity;
      });
    }

    final mode =
        prefs.getString(_locationModeKey) ??
            _locationModeAuto;

    debugPrint(
      '📍 HOME LOCATION | mode=$mode',
    );

    if (mode == _locationModeManual) {
      _latitude =
          prefs.getDouble(
            'prayer_manual_latitude',
          ) ??
              _latitude;

      _longitude =
          prefs.getDouble(
            'prayer_manual_longitude',
          ) ??
              _longitude;

      debugPrint(
        '📍 HOME MANUAL LOCATION | '
            'lat=$_latitude | '
            'lng=$_longitude',
      );
    } else {
      await _useAutomaticLocation(
        showError: false,
      );

      debugPrint(
        '📍 HOME GPS LOCATION | '
            'lat=$_latitude | '
            'lng=$_longitude',
      );
    }

    _locationReady = true;

    await _reloadPrayerTimesAndAlarms();
  }

  Future<void> _useAutomaticLocation({
    bool showError = true,
  })
  async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception(
          'يرجى تشغيل خدمة الموقع GPS',
        );
      }

      var permission =
      await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission ==
          LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        throw Exception(
          'لم يتم السماح بالوصول إلى الموقع',
        );
      }

      final position =
      await Geolocator.getCurrentPosition(
        locationSettings:
        const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      try {
        final timezoneInfo = await FlutterTimezone.getLocalTimezone();
        _locationTimezone = timezoneInfo.identifier;
      } catch (e) {
        debugPrint('❌ AUTO TIMEZONE LOOKUP ERROR | $e');
      }

      // ============================================================
      // GET CITY NAME FROM GPS COORDINATES
      // ============================================================

      final detectedCity =
      await _getCityNameFromCoordinates(
        _latitude,
        _longitude,
      );

      _cityName = detectedCity;

      debugPrint(
        '📍 GPS CITY DETECTED | '
            'city=$_cityName | '
            'lat=$_latitude | '
            'lng=$_longitude',
      );

      final prefs =
      await SharedPreferences.getInstance();

      await prefs.setString(
        _locationModeKey,
        _locationModeAuto,
      );

      await prefs.setString(
        'prayer_city_name',
        _cityName,
      );

      await prefs.setString(
        _locationTimezoneKey,
        _locationTimezone,
      );

      await prefs.setDouble(
        prayerLastLatitudePrefsKey,
        _latitude,
      );

      await prefs.setDouble(
        prayerLastLongitudePrefsKey,
        _longitude,
      );

      if (mounted) {
        setState(() {
          _cityName = detectedCity;
        });
      }
    } catch (e) {
      if (showError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$e',
              style: TextStyle(
                fontSize: 14.sp,
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _reloadPrayerTimesAndAlarms() async {
    if (!_locationReady) {
      return;
    }

    _adhanScheduled = false;

    _prayerBloc.add(
      LoadPrayerTimes(
        latitude: _latitude,
        longitude: _longitude,
        date: DateTime.now(),
      ),
    );
  }

  Future<String> _getCityNameFromCoordinates(
      double latitude,
      double longitude,
      )
  async {
    try {
      debugPrint(
        '🌍 START REVERSE GEOCODING | '
            'lat=$latitude | lng=$longitude',
      );

      final placemarks =
      await Geocoding().placemarkFromCoordinates(
        latitude,
        longitude,
        locale: const Locale(
          'en',
          'US',
        ),
      );

      debugPrint(
        '🌍 GEOCODING RESULTS COUNT = '
            '${placemarks.length}',
      );

      if (placemarks.isEmpty) {
        debugPrint(
          '❌ GEOCODING RETURNED EMPTY',
        );

        return 'Current';
      }

      for (final place in placemarks) {
        debugPrint(
          '📍 PLACE | '
              'name=${place.name} | '
              'locality=${place.locality} | '
              'subLocality=${place.subLocality} | '
              'subAdministrativeArea='
              '${place.subAdministrativeArea} | '
              'administrativeArea='
              '${place.administrativeArea} | '
              'country=${place.country}',
        );
      }

      final place = placemarks.first;

      final city =
      place.locality?.trim();

      if (city != null && city.isNotEmpty) {
        debugPrint(
          '✅ CITY FOUND = $city',
        );

        return city;
      }

      final subLocality =
      place.subLocality?.trim();

      if (subLocality != null &&
          subLocality.isNotEmpty) {
        debugPrint(
          '✅ SUBLOCALITY FOUND = '
              '$subLocality',
        );

        return subLocality;
      }

      final subAdministrativeArea =
      place.subAdministrativeArea?.trim();

      if (subAdministrativeArea != null &&
          subAdministrativeArea.isNotEmpty) {
        debugPrint(
          '✅ SUB ADMINISTRATIVE AREA FOUND = '
              '$subAdministrativeArea',
        );

        return subAdministrativeArea;
      }

      final administrativeArea =
      place.administrativeArea?.trim();

      if (administrativeArea != null &&
          administrativeArea.isNotEmpty) {
        debugPrint(
          '✅ ADMINISTRATIVE AREA FOUND = '
              '$administrativeArea',
        );

        return administrativeArea;
      }

      debugPrint(
        '⚠️ NO CITY FIELD FOUND',
      );

      return 'Current Location';
    } catch (e, stackTrace) {
      debugPrint(
        '❌❌❌ REVERSE GEOCODING FAILED',
      );

      debugPrint(
        '❌ ERROR TYPE = ${e.runtimeType}',
      );

      debugPrint(
        '❌ ERROR = $e',
      );

      debugPrint(
        '❌ STACK = $stackTrace',
      );

      return 'Current Location';
    }
  }

  Future<void> _onLocationStateChanged(
      BuildContext context,
      LocationState state,
      ) async {
    if (state.status == LocationStatus.loading) {
      debugPrint('📍 Location loading...');
      return;
    }

    if (state.status == LocationStatus.failure) {
      debugPrint(
        '❌ LOCATION ERROR = ${state.errorMessage}',
      );
      return;
    }

    if (state.status != LocationStatus.success ||
        state.currentLocation == null) {
      return;
    }

    final location = state.currentLocation!;

    final newLat = location.latitude;
    final newLng = location.longitude;

    debugPrint(
      '📍 CURRENT LOCATION SUCCESS | '
          'lat=$newLat | '
          'lng=$newLng',
    );

    // Get city
    String newCity = location.city.trim();

    if (newCity.isEmpty) {
      newCity = await _getCityNameFromCoordinates(
        newLat,
        newLng,
      );
    }

    // Save AUTO location
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _locationModeKey,
      _locationModeAuto,
    );

    await prefs.setString(
      'prayer_city_name',
      newCity,
    );

    if (location.timezone.isNotEmpty) {
      await prefs.setString(
        _locationTimezoneKey,
        location.timezone,
      );
    }

    await prefs.setDouble(
      prayerLastLatitudePrefsKey,
      newLat,
    );

    await prefs.setDouble(
      prayerLastLongitudePrefsKey,
      newLng,
    );

    debugPrint(
      '💾 LOCATION SAVED | '
          'mode=auto | '
          'lat=$newLat | '
          'lng=$newLng | '
          'city=$newCity',
    );

    if (!mounted) return;

    setState(() {
      _latitude = newLat;
      _longitude = newLng;
      _cityName = newCity;
      if (location.timezone.isNotEmpty) {
        _locationTimezone = location.timezone;
      }
      _locationReady = true;
      _adhanScheduled = false;
    });

    debugPrint(
      '🏠 HOME LOCATION UPDATED | '
          'lat=$_latitude | '
          'lng=$_longitude',
    );

    // IMPORTANT:
    // Don't cancel alarms here.
    // Scheduler owns cancel/reschedule.

    _prayerBloc.add(
      LoadPrayerTimes(
        latitude: newLat,
        longitude: newLng,
        date: DateTime.now(),
      ),
    );

    debugPrint(
      '🔄 PRAYER TIMES RELOAD REQUESTED | '
          'lat=$newLat | '
          'lng=$newLng',
    );
  }
}