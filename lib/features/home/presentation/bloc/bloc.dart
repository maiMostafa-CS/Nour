import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
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
    on<CheckLocationIfChanged>(_onCheckLocationIfChanged);
    on<ClearAutoUpdateMessage>(_onClearAutoUpdateMessage);
  }

  final SharedPreferences _prefs;
  final GetCurrentLocationUseCase _getCurrentLocation;
  final GetPrayerTimes _getPrayerTimes;
  final AdhanSchedulerService _scheduler;

  StreamSubscription<Position>? _positionSubscription;
  bool _isCheckingLocation = false;

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
  ) async {
    debugPrint('═══════════════════════════════════════════');
    debugPrint('🏠 _onLoadHome CALLED');
    debugPrint('═══════════════════════════════════════════');

    emit(state.copyWith(loading: true, clearError: true));

    try {
      // ═══════════════════════════════════════════════════════
      // 1. Read all saved values
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
      // 2. Try the saved location first (manual or auto)
      // ═══════════════════════════════════════════════════════
      final savedLat = _prefs.getDouble(_manualLatKey) ??
          _prefs.getDouble(prayerLastLatitudePrefsKey);
      final savedLng = _prefs.getDouble(_manualLngKey) ??
          _prefs.getDouble(prayerLastLongitudePrefsKey);

      if (savedLat != null && savedLng != null) {
        // ✅ A saved location exists → use it immediately for fast startup
        latitude = savedLat;
        longitude = savedLng;

        debugPrint('✅ USING SAVED LOCATION:');
        debugPrint('   latitude:  $latitude');
        debugPrint('   longitude: $longitude');
        debugPrint('   city:      "$resolvedCity"');
        debugPrint('   timezone:  "$resolvedTimezone"');
      } else {
        // ⚠️ First time → GPS is required
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

          latitude = state.latitude;
          longitude = state.longitude;

          debugPrint('⚠️ Using DEFAULT location: $latitude, $longitude');
        }
      }

      // ═══════════════════════════════════════════════════════
      // 3. Schedule adhan
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

      // ═══════════════════════════════════════════════════════
      // 4. Auto check in background if location changed
      // ═══════════════════════════════════════════════════════
      unawaited(_checkIfLocationChanged());
      _startLocationTracking();
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

    if (!event.isAutoDetected) {
      emit(state.copyWith(
        loading: true,
        scheduling: false,
        clearError: true,
      ));
    }

    try {
      await _saveAutoLocation(location);

      final newCity = location.city.trim().isEmpty
          ? state.cityName
          : location.city.trim();
      final newTimezone = location.timezone.trim().isEmpty
          ? state.timezone
          : location.timezone.trim();

      await _loadAndSchedule(
        emit,
        latitude: location.latitude,
        longitude: location.longitude,
        cityName: newCity,
        timezone: newTimezone,
        cancelOldAlarms: true,
      );

      if (event.isAutoDetected) {
        emit(state.copyWith(
          autoUpdateMessage: 'تم رصد تغير موقعك وتحديث مواقيت الصلاة تلقائيًا: $newCity',
        ));
      }
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

  Future<void> _onCheckLocationIfChanged(
    CheckLocationIfChanged event,
    Emitter<HomeState> emit,
  ) async {
    await _checkIfLocationChanged();
  }

  void _onClearAutoUpdateMessage(
    ClearAutoUpdateMessage event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(clearAutoUpdateMessage: true));
  }

  // ═══════════════════════════════════════════════════════════
  // Background Auto-Update Check
  // ═══════════════════════════════════════════════════════════
  Future<void> _checkIfLocationChanged() async {
    if (_isCheckingLocation) return;
    _isCheckingLocation = true;

    try {
      final mode = _prefs.getString(_modeKey) ?? _autoMode;
      if (mode != _autoMode) {
        debugPrint('📍 Location mode is manual, skipping auto-check');
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('📍 GPS service disabled, skipping auto-check');
        return;
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('📍 Location permission not granted, skipping auto-check');
        return;
      }

      debugPrint('🔍 Checking GPS in background to detect location change...');
      final newLocation = await _getCurrentLocation().timeout(
        const Duration(seconds: 12),
      );

      final currentLat = state.latitude;
      final currentLng = state.longitude;

      final distanceMeters = Geolocator.distanceBetween(
        currentLat,
        currentLng,
        newLocation.latitude,
        newLocation.longitude,
      );

      debugPrint(
        '📍 Auto-check distance: ${(distanceMeters / 1000).toStringAsFixed(2)} km '
        '(Current: ${state.cityName}, Detected: ${newLocation.city})',
      );

      final cityChanged = newLocation.city.trim().isNotEmpty &&
          state.cityName.trim().isNotEmpty &&
          newLocation.city.trim().toLowerCase() != state.cityName.trim().toLowerCase();

      // If user moved more than 5 kilometers or city changed:
      if (distanceMeters > 5000 || cityChanged) {
        debugPrint('🚗 SIGNIFICANT LOCATION CHANGE DETECTED:');
        debugPrint('   Old: ${state.cityName} ($currentLat, $currentLng)');
        debugPrint('   New: ${newLocation.city} (${newLocation.latitude}, ${newLocation.longitude})');
        debugPrint('   Distance: ${(distanceMeters / 1000).toStringAsFixed(1)} km');

        add(HomeLocationChanged(newLocation, isAutoDetected: true));
      } else {
        debugPrint('✅ Location has not changed significantly. No update needed.');
      }
    } catch (e) {
      debugPrint('⚠️ Auto-location check error: $e');
    } finally {
      _isCheckingLocation = false;
    }
  }

  void _startLocationTracking() {
    _positionSubscription?.cancel();

    final mode = _prefs.getString(_modeKey) ?? _autoMode;
    if (mode != _autoMode) return;

    try {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 5000, // Trigger only when moved >= 5 km
        ),
      ).listen(
        (position) {
          debugPrint('📡 Significant movement event: ${position.latitude}, ${position.longitude}');
          _checkIfLocationChanged();
        },
        onError: (e) {
          debugPrint('⚠️ Position stream error: $e');
        },
      );
    } catch (e) {
      debugPrint('⚠️ Failed to start position stream: $e');
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

    await _prefs.setDouble(prayerScheduledLatitudePrefsKey, location.latitude);
    await _prefs.setDouble(prayerScheduledLongitudePrefsKey, location.longitude);

    await _prefs.setDouble(prayerLastLatitudePrefsKey, location.latitude);
    await _prefs.setDouble(prayerLastLongitudePrefsKey, location.longitude);

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

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}