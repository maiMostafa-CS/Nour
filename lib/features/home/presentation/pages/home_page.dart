import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/adhan_scheduler_service.dart';
import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/adhan_scheduler_service.dart';
import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/config/prayer_scheduler_config.dart';
import '../../../../injection_container.dart';
import '../../../hijri_calendar/domain/usecases/get_hijri_date.dart';
import '../../../hijri_calendar/presentation/bloc/hijri_calendar_bloc.dart';
import '../../../locations/domain/entity/current_location_entity.dart';
import '../../../locations/domain/entity/location_entity.dart';
import '../../../locations/presentation/pages/locationPage.dart';
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
  late final HijriCalendarBloc _hijriCalendarBloc;
  late final GetHijriDate _getHijriDate;
  @override
  void dispose() {
    debugPrint(
      '💀💀💀 HOME PAGE DISPOSE: ${identityHashCode(this)}',
    );
    _timer?.cancel();
    super.dispose();
  }

  late final PrayerBloc _prayerBloc;

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
      child: BlocListener<PrayerBloc, PrayerState>(
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
              latitude: _latitude,
              longitude: _longitude,
            );

            _adhanScheduled = true;

            debugPrint('✅ ADHAN SCHEDULED SUCCESSFULLY');
          } catch (e, stackTrace) {
            _adhanScheduled = false;

            debugPrint('❌ ADHAN SCHEDULING FAILED: $e');
            debugPrint('$stackTrace');
          }
        },
        child: Directionality(
          textDirection: widgets.TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              backgroundColor: const Color(0xFFE8E8CE),
              elevation: 0,
              title: _buildHijriDate(),
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
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (state is PrayerLoaded) {
                    final prayerTimes = state.prayerTimes;

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                _buildTopBar(),
                                // ElevatedButton(
                                //   onPressed: () async {
                                //     await AutoRenewTest.run();
                                //   },
                                //   child: const Text(
                                //     '🧪 اختبار Auto-Renew',
                                //   ),
                                // ),
                                const SizedBox(height: 18),
                                NextPrayerCard(
                                  prayerTimes: prayerTimes,
                                ),
                                const SizedBox(height: 18),
                                _buildSectionTitle(
                                  'مواقيت الصلاة',
                                ),
                                const SizedBox(height: 10),
                                PrayerTimesWidget(
                                  prayerTimes: prayerTimes,
                                ),
                                const SizedBox(height: 18),
                                BuildMainGrid(),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return const Center(
                    child: Text('جاري التحميل...'),
                  );
                },
              ),
            ),
            bottomNavigationBar: CustomBottomNavigation(
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
    );
  }

  Widget _buildTopBar() {
    return
    Row(
      children: [
        Flexible(
          child: InkWell(
            onTap: _openLocationPage,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 6,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 25,
                    color: Color(0xFF222222),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      _cityName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );  }
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF222222),
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

    // ============================================================
    // CURRENT GPS LOCATION
    // ============================================================

    if (location is CurrentLocationEntity) {
      lat = location.latitude;
      lng = location.longitude;
      cityName = location.city;

      debugPrint(
        '📍 CURRENT GPS | '
            'city=${location.city} | '
            'country=${location.country} | '
            'lat=$lat | '
            'lng=$lng',
      );


      // cityName = await _getCityNameFromCoordinates(
      //   lat,
      //   lng,
      // );

      debugPrint(
        '🏙️ GPS CITY = $cityName',
      );

    }    // ============================================================
    // MANUAL LOCATION
    // ============================================================

    else if (location is LocationEntity) {
      lat = location.latitude;
      lng = location.longitude;

      cityName = location.city;

      debugPrint(
        '📍 MANUAL LOCATION FROM PAGE | '
            'city=${location.city} | '
            'country=${location.country} | '
            'lat=$lat | '
            'lng=$lng',
      );
    }  // ============================================================
    // INVALID
    // ============================================================

  else {
    debugPrint(
      '❌ Invalid location type: ${location.runtimeType}',
    );
    return;
  }

    final prefs = await SharedPreferences.getInstance();

    // ============================================================
    // SAVE LOCATION MODE
    // ============================================================

    await prefs.setString(
      'prayer_city_name',
      cityName??"",
    );
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
      _cityName = cityName??"";
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
    final prefs = await SharedPreferences.getInstance();
    final savedCity = prefs.getString('prayer_city_name');

    if (savedCity != null && mounted) {
      setState(() {
        _cityName = savedCity;
      });
    }
    final mode =
        prefs.getString(_locationModeKey) ?? _locationModeAuto;

    debugPrint(
      '📍 HOME LOCATION | mode=$mode',
    );

    if (mode == _locationModeManual) {
      _latitude =
          prefs.getDouble('prayer_manual_latitude') ?? _latitude;

      _longitude =
          prefs.getDouble('prayer_manual_longitude') ?? _longitude;

      debugPrint(
        '📍 HOME MANUAL LOCATION | '
            'lat=$_latitude | '
            'lng=$_longitude',
      );
    } else {
      await _useAutomaticLocation(showError: false);

      debugPrint(
        '📍 HOME GPS LOCATION | '
            'lat=$_latitude | '
            'lng=$_longitude',
      );
    }

    _locationReady = true;

    await _reloadPrayerTimesAndAlarms();
  }
  Future<void> _useAutomaticLocation({bool showError = true}) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('يرجى تشغيل خدمة الموقع GPS');
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('لم يتم السماح بالوصول إلى الموقع');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      // ============================================================
      // GET CITY NAME FROM GPS COORDINATES
      // ============================================================

      final detectedCity = await _getCityNameFromCoordinates(
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

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        _locationModeKey,
        _locationModeAuto,
      );

      await prefs.setString(
        'prayer_city_name',
        _cityName,
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
            content: Text('$e'),
          ),
        );
      }
    }
  }
  Future<void> _reloadPrayerTimesAndAlarms() async {
    if (!_locationReady) return;
    _adhanScheduled = false;
    _prayerBloc.add(LoadPrayerTimes(
      latitude: _latitude,
      longitude: _longitude,
      date: DateTime.now(),
    ));
  }
  Future<String> _getCityNameFromCoordinates(
      double latitude,
      double longitude,
      ) async {
    try {
      debugPrint(
        '🌍 START REVERSE GEOCODING | '
            'lat=$latitude | lng=$longitude',
      );

      final placemarks = await Geocoding().placemarkFromCoordinates(
        latitude,
        longitude,
        locale: const Locale('en', 'US'),
      );

      debugPrint(
        '🌍 GEOCODING RESULTS COUNT = ${placemarks.length}',
      );

      if (placemarks.isEmpty) {
        debugPrint('❌ GEOCODING RETURNED EMPTY');
        return 'Current ';
      }

      for (final place in placemarks) {
        debugPrint(
          '📍 PLACE | '
              'name=${place.name} | '
              'locality=${place.locality} | '
              'subLocality=${place.subLocality} | '
              'subAdministrativeArea=${place.subAdministrativeArea} | '
              'administrativeArea=${place.administrativeArea} | '
              'country=${place.country}',
        );
      }

      final place = placemarks.first;

      final city = place.locality?.trim();

      if (city != null && city.isNotEmpty) {
        debugPrint('✅ CITY FOUND = $city');
        return city;
      }

      final subLocality = place.subLocality?.trim();

      if (subLocality != null && subLocality.isNotEmpty) {
        debugPrint('✅ SUBLOCALITY FOUND = $subLocality');
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

      debugPrint('⚠️ NO CITY FIELD FOUND');

      return 'Current Location';
    } catch (e, stackTrace) {
      debugPrint('❌❌❌ REVERSE GEOCODING FAILED');
      debugPrint('❌ ERROR TYPE = ${e.runtimeType}');
      debugPrint('❌ ERROR = $e');
      debugPrint('❌ STACK = $stackTrace');

      return 'Current Location';
    }
  }
  Widget _buildHijriDate() {
    final now = DateTime.now();

    final hijriDate = _getHijriDate(now);

    const arabicWeekDays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    final weekDay = arabicWeekDays[now.weekday - 1];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          weekDay,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '${hijriDate.day} '
              '${hijriDate.monthName} '
              '${hijriDate.year} هـ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF555555),
          ),
        ),
      ],
    );
  }}