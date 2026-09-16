import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/adhan_scheduler_service.dart';
import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/config/prayer_scheduler_config.dart';
import '../../../locations/domain/entity/current_location_entity.dart';
import '../../../locations/domain/usecase/get_current_location.dart';
import '../../../prayer_times/domain/usecases/get_prayer_times.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required SharedPreferences prefs,
    required GetCurrentLocationUseCase getCurrentLocation,
    required GetPrayerTimes getPrayerTimes,
    required AdhanSchedulerService scheduler,
  })  : _prefs = prefs,
        _getCurrentLocation = getCurrentLocation,
        _getPrayerTimes = getPrayerTimes,
        _scheduler = scheduler,
        super(const HomeState()) {
    on<LoadHome>(_onLoadHome);
    on<HomeLocationChanged>(_onLocationChanged);
    on<RefreshLocation>(_onRefreshLocation);

  }

  final SharedPreferences _prefs;
  final GetCurrentLocationUseCase _getCurrentLocation;
  final GetPrayerTimes _getPrayerTimes;
  final AdhanSchedulerService _scheduler;

  static const _modeKey = 'prayer_location_mode';
  static const _manualMode = 'manual';
  static const _autoMode = 'auto';
  static const _cityKey = 'prayer_city_name';
  static const _timezoneKey = 'prayer_location_timezone';
  static const _manualLatKey = 'prayer_manual_latitude';
  static const _manualLngKey = 'prayer_manual_longitude';


  Future<void> _onLoadHome(
      LoadHome event,
      Emitter<HomeState> emit,
      )
  async {
    debugPrint('═══════════════════════════════════════════');
    debugPrint('🏠 _onLoadHome CALLED');
    debugPrint('═══════════════════════════════════════════');

    emit(state.copyWith(loading: true, clearError: true));

    try {
      // ═══════════════════════════════════════════════════════
      // 1. اقرأ كل القيم المحفوظة
      // ═══════════════════════════════════════════════════════
      final city = _prefs.getString(_cityKey) ?? state.cityName;
      final timezone = _prefs.getString(_timezoneKey) ?? state.timezone;
      final mode = _prefs.getString(_modeKey) ?? _autoMode;

      debugPrint('📖 READ FROM SHARED PREFERENCES:');
      debugPrint('   mode: $mode');
      debugPrint('   city: "$city"');
      debugPrint('   timezone: $timezone');
      debugPrint('   _manualLatKey: ${_prefs.getDouble(_manualLatKey)}');
      debugPrint('   _manualLngKey: ${_prefs.getDouble(_manualLngKey)}');
      debugPrint('   prayerLastLat: ${_prefs.getDouble(prayerLastLatitudePrefsKey)}');
      debugPrint('   prayerLastLng: ${_prefs.getDouble(prayerLastLongitudePrefsKey)}');
      debugPrint('───────────────────────────────────────────');

      double latitude;
      double longitude;
      String resolvedCity = city;
      String resolvedTimezone = timezone;

      // ═══════════════════════════════════════════════════════
      // 2. جرّب الموقع المحفوظ الأول (سواء manual أو auto)
      // ═══════════════════════════════════════════════════════
      final savedLat = _prefs.getDouble(_manualLatKey) ??
          _prefs.getDouble(prayerLastLatitudePrefsKey);
      final savedLng = _prefs.getDouble(_manualLngKey) ??
          _prefs.getDouble(prayerLastLongitudePrefsKey);

      if (savedLat != null && savedLng != null) {
        // ✅ فيه موقع محفوظ → استخدمه فوراً
        latitude = savedLat;
        longitude = savedLng;

        debugPrint('✅ USING SAVED LOCATION:');
        debugPrint('   latitude:  $latitude');
        debugPrint('   longitude: $longitude');
        debugPrint('   city:      "$resolvedCity"');
        debugPrint('   timezone:  "$resolvedTimezone"');
        debugPrint('   (NO GPS NEEDED)');
      } else {
        // ⚠️ أول مرة → محتاج GPS
        debugPrint('📡 NO SAVED LOCATION → fetching GPS...');

        CurrentLocationEntity location;
        try {
          location = await _getCurrentLocation().timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint('⏰ GPS TIMEOUT!');
              throw Exception('Location timeout');
            },
          );

          debugPrint('📍 GPS LOCATION RECEIVED:');
          debugPrint('   latitude:  ${location.latitude}');
          debugPrint('   longitude: ${location.longitude}');
          debugPrint('   city:      "${location.city}"');
          debugPrint('   timezone:  "${location.timezone}"');

          latitude = location.latitude;
          longitude = location.longitude;

          if (location.city.trim().isNotEmpty) {
            resolvedCity = location.city.trim();
          }
          if (location.timezone.trim().isNotEmpty) {
            resolvedTimezone = location.timezone.trim();
          }

          await _saveAutoLocation(location);
        } catch (e, stackTrace) {
          debugPrint('❌ GPS FAILED: $e');
          debugPrint('$stackTrace');

          // Fallback للـ default
          latitude = state.latitude;
          longitude = state.longitude;

          debugPrint('⚠️ Using DEFAULT location: $latitude, $longitude');
        }
      }

      // ═══════════════════════════════════════════════════════
      // 3. جدول الأذان
      // ═══════════════════════════════════════════════════════
      debugPrint('🚀 CALLING _loadAndSchedule:');
      debugPrint('   latitude:  $latitude');
      debugPrint('   longitude: $longitude');
      debugPrint('   cityName:  "$resolvedCity"');
      debugPrint('   timezone:  "$resolvedTimezone"');

      await _loadAndSchedule(
        emit,
        latitude: latitude,
        longitude: longitude,
        cityName: resolvedCity,
        timezone: resolvedTimezone,
        cancelOldAlarms: false,
      );

      debugPrint('✅ _onLoadHome COMPLETED');
    } catch (e, stackTrace) {
      debugPrint('❌ HOME LOAD FAILED: $e');
      debugPrint('$stackTrace');
      emit(state.copyWith(
        loading: false,
        scheduling: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLocationChanged(
    HomeLocationChanged event,
    Emitter<HomeState> emit,
  ) async {
    final location = event.location;

    emit(state.copyWith(
      loading: true,
      scheduling: false,
      clearError: true,
    ));

    try {
      await _saveAutoLocation(location);

      await _loadAndSchedule(
        emit,
        latitude: location.latitude,
        longitude: location.longitude,
        cityName: location.city.trim().isEmpty
            ? state.cityName
            : location.city.trim(),
        timezone: location.timezone.trim().isEmpty
            ? state.timezone
            : location.timezone.trim(),
        cancelOldAlarms: true,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ HOME LOCATION CHANGE FAILED: $e');
      debugPrint('$stackTrace');
      emit(state.copyWith(
        loading: false,
        scheduling: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _loadAndSchedule(
      Emitter<HomeState> emit, {
        required double latitude,
        required double longitude,
        required String cityName,
        required String timezone,
        required bool cancelOldAlarms,
      }) async {
    if (cancelOldAlarms) {
      try {
        await _scheduler.cancelAdhans();
        debugPrint('✅ OLD ADHAN ALARMS CANCELLED');
      } catch (e, stackTrace) {
        debugPrint('❌ CANCEL OLD ALARMS FAILED: $e');
        debugPrint('$stackTrace');
      }
    }

    tz.Location location;
    try {
      location = tz.getLocation(timezone);
    } catch (_) {
      location = tz.getLocation('Africa/Cairo');
    }

    final nowInLocation = tz.TZDateTime.now(location);
    final dateInLocation = tz.TZDateTime(
      location,
      nowInLocation.year,
      nowInLocation.month,
      nowInLocation.day,
      12, 0, 0,
    );

    final prayerTimes = await _getPrayerTimes(
      latitude: latitude,
      longitude: longitude,
      date: dateInLocation,
    );

    emit(state.copyWith(
      loading: false,
      scheduling: true,
      latitude: latitude,
      longitude: longitude,
      cityName: cityName,
      timezone: timezone,
      prayerTimes: prayerTimes,
    ));

    try {
      await _scheduler.showNextPrayerCountdown(prayerTimes);
      await _scheduler.schedulePrayerAdhan(
        prayerTimes,
        latitude: latitude,
        longitude: longitude,
      );
      debugPrint(
        '✅ ADHAN SCHEDULED | lat=$latitude | lng=$longitude',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ADHAN SCHEDULING FAILED: $e');
      debugPrint('$stackTrace');
    }

    emit(state.copyWith(
      loading: false,
      scheduling: false,
      clearError: true,
    ));
  }
  Future<void> _saveAutoLocation(CurrentLocationEntity location) async {
    debugPrint('💾 _saveAutoLocation CALLED');
    debugPrint('   → city:     "${location.city}"');
    debugPrint('   → timezone: "${location.timezone}"');
    debugPrint('   → latitude: ${location.latitude}');
    debugPrint('   → longitude: ${location.longitude}');

    await _prefs.setString(_modeKey, _autoMode);
    await _prefs.setString(_cityKey, location.city);
    await _prefs.setString(_timezoneKey, location.timezone);

    await _prefs.setDouble(_manualLatKey, location.latitude);
    await _prefs.setDouble(_manualLngKey, location.longitude);

    // ✅ المفتاح اللي cancelAll بتقرأ منه
    await _prefs.setDouble(prayerScheduledLatitudePrefsKey, location.latitude);
    await _prefs.setDouble(prayerScheduledLongitudePrefsKey, location.longitude);

    // (اختياري) سيبهم لو محتاجينهم في مكان تاني
    await _prefs.setDouble(prayerLastLatitudePrefsKey, location.latitude);
    await _prefs.setDouble(prayerLastLongitudePrefsKey, location.longitude);

    // ✅ VERIFY من نفس المفاتيح
    final checkLat = _prefs.getDouble(prayerScheduledLatitudePrefsKey);
    final checkLng = _prefs.getDouble(prayerScheduledLongitudePrefsKey);

    if (checkLat == null || checkLng == null) {
      throw StateError(
        '🔴 CRITICAL: Location NOT persisted! '
            'lat=$checkLat lng=$checkLng',
      );
    }

    debugPrint('✅ VERIFY:');
    debugPrint('   scheduledLat: $checkLat');
    debugPrint('   scheduledLng: $checkLng');
  }

  Future<void> _onRefreshLocation(
      RefreshLocation event,
      Emitter<HomeState> emit,
      ) async {
    debugPrint('🔄 REFRESH LOCATION → fetching GPS...');

    emit(state.copyWith(
      loading: true,
      scheduling: false,
      clearError: true,
    ));

    try {
      final location = await _getCurrentLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Location timeout'),
      );

      debugPrint('📍 GPS LOCATION RECEIVED:');
      debugPrint('   latitude:  ${location.latitude}');
      debugPrint('   longitude: ${location.longitude}');
      debugPrint('   city:      "${location.city}"');
      debugPrint('   timezone:  "${location.timezone}"');

      // احفظ الموقع الجديد
      await _saveAutoLocation(location);

      // جدول الأذان من جديد
      await _loadAndSchedule(
        emit,
        latitude: location.latitude,
        longitude: location.longitude,
        cityName: location.city.trim().isEmpty
            ? state.cityName
            : location.city.trim(),
        timezone: location.timezone.trim().isEmpty
            ? state.timezone
            : location.timezone.trim(),
        cancelOldAlarms: true,
      );

      debugPrint('✅ REFRESH LOCATION DONE');
    } catch (e, stackTrace) {
      debugPrint('❌ REFRESH LOCATION FAILED: $e');
      debugPrint('$stackTrace');
      emit(state.copyWith(
        loading: false,
        scheduling: false,
        errorMessage: e.toString(),
      ));
    }
  }

}