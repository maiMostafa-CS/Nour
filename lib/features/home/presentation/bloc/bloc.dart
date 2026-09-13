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
  ) async {
    emit(state.copyWith(loading: true, clearError: true));

    try {
      final city = _prefs.getString(_cityKey) ?? state.cityName;
      final timezone =
          _prefs.getString(_timezoneKey) ?? state.timezone;
      final mode = _prefs.getString(_modeKey) ?? _autoMode;

      double latitude;
      double longitude;
      String resolvedCity = city;
      String resolvedTimezone = timezone;

      if (mode == _manualMode) {
        latitude = _prefs.getDouble(_manualLatKey) ?? state.latitude;
        longitude = _prefs.getDouble(_manualLngKey) ?? state.longitude;
      } else {
        final location = await _getCurrentLocation();
        latitude = location.latitude;
        longitude = location.longitude;
        if (location.city.trim().isNotEmpty) {
          resolvedCity = location.city.trim();
        }
        if (location.timezone.trim().isNotEmpty) {
          resolvedTimezone = location.timezone.trim();
        }
        await _saveAutoLocation(location);
      }

      await _loadAndSchedule(
        emit,
        latitude: latitude,
        longitude: longitude,
        cityName: resolvedCity,
        timezone: resolvedTimezone,
        cancelOldAlarms: false,
      );
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

    // ✅ التعديل: احسب التاريخ بتوقيت المكان المختار
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
      12, 0, 0,   // منتصف النهار عشان نتجنب مشاكل حدود اليوم
    );

    final prayerTimes = await _getPrayerTimes(
      latitude: latitude,
      longitude: longitude,
      date: dateInLocation,   // ← بدل DateTime.now()
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
    await _prefs.setString(_modeKey, _autoMode);
    await _prefs.setString(_cityKey, location.city);
    await _prefs.setString(_timezoneKey, location.timezone);
    await _prefs.setDouble(
      prayerLastLatitudePrefsKey,
      location.latitude,
    );
    await _prefs.setDouble(
      prayerLastLongitudePrefsKey,
      location.longitude,
    );
  }
}
