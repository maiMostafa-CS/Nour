import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/hijri_date_entity.dart';
import '../../domain/usecases/get_hijri_date.dart';
import '../../domain/usecases/get_hijri_month.dart';

import '../../../prayer_times/domain/usecases/get_prayer_times.dart';

import 'hijri_calendar_event.dart';
import 'hijri_calendar_state.dart';

class HijriCalendarBloc
    extends Bloc<HijriCalendarEvent, HijriCalendarState> {
  final GetHijriDate getHijriDate;
  final GetHijriMonth getHijriMonth;
  final GetPrayerTimes getPrayerTimes;

  HijriCalendarBloc({
    required this.getHijriDate,
    required this.getHijriMonth,
    required this.getPrayerTimes,
  }) : super(const HijriCalendarInitial()) {
    on<LoadHijriCalendar>(_onLoad);
    on<SelectHijriDate>(_onSelectDate);
    on<NextHijriMonth>(_onNextMonth);
    on<PreviousHijriMonth>(_onPreviousMonth);
  }

  // ============================================================
  // LOAD CURRENT HIJRI CALENDAR
  // ============================================================

  Future<void> _onLoad(
      LoadHijriCalendar event,
      Emitter<HijriCalendarState> emit,
      ) async {
    emit(const HijriCalendarLoading());

    try {
      final today = DateTime.now();

      // ----------------------------------------------------------
      // GET CURRENT SAVED LOCATION
      // ----------------------------------------------------------

      final location = await _getSavedLocation();

      final latitude = location['latitude']!;
      final longitude = location['longitude']!;

      debugPrint(
        '📍 HIJRI CALENDAR LOCATION | '
            'lat=$latitude | '
            'lng=$longitude',
      );

      // ----------------------------------------------------------
      // GET TODAY HIJRI DATE
      // ----------------------------------------------------------

      final hijriDate = getHijriDate(today);

      debugPrint(
        '🌙 HIJRI TODAY | '
            '${hijriDate.day} '
            '${hijriDate.monthName} '
            '${hijriDate.year}',
      );

      // ----------------------------------------------------------
      // GET HIJRI MONTH
      // ----------------------------------------------------------

      final dates = getHijriMonth(
        year: hijriDate.year,
        month: hijriDate.month,
      );

      // ----------------------------------------------------------
      // GET PRAYER TIMES
      // ----------------------------------------------------------

      final prayerTimes = await getPrayerTimes(
        latitude: latitude,
        longitude: longitude,
        date: today,
      );

      debugPrint(
        '🕌 HIJRI CALENDAR PRAYER TIMES LOADED | '
            'lat=$latitude | '
            'lng=$longitude',
      );

      // ----------------------------------------------------------
      // EMIT
      // ----------------------------------------------------------

      emit(
        HijriCalendarLoaded(
          dates: dates,
          year: hijriDate.year,
          month: hijriDate.month,
          selectedDate: hijriDate,
          prayerTimes: prayerTimes,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ HIJRI CALENDAR LOAD ERROR: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      emit(
        HijriCalendarError(
          'حدث خطأ أثناء تحميل التقويم: $e',
        ),
      );
    }
  }

  // ============================================================
  // SELECT HIJRI DATE
  // ============================================================

  Future<void> _onSelectDate(
      SelectHijriDate event,
      Emitter<HijriCalendarState> emit,
      ) async {
    final currentState = state;

    if (currentState is! HijriCalendarLoaded) {
      return;
    }

    try {
      debugPrint(
        '📅 HIJRI DATE SELECTED | '
            '${event.date}',
      );

      // ----------------------------------------------------------
      // CONVERT GREGORIAN -> HIJRI
      // ----------------------------------------------------------

      final selectedHijriDate =
      getHijriDate(event.date);

      // ----------------------------------------------------------
      // GET CURRENT SAVED LOCATION
      // ----------------------------------------------------------

      final location = await _getSavedLocation();

      final latitude = location['latitude']!;
      final longitude = location['longitude']!;

      debugPrint(
        '📍 HIJRI SELECT DATE LOCATION | '
            'lat=$latitude | '
            'lng=$longitude',
      );

      // ----------------------------------------------------------
      // GET PRAYER TIMES FOR SELECTED DATE
      // ----------------------------------------------------------

      final prayerTimes = await getPrayerTimes(
        latitude: latitude,
        longitude: longitude,
        date: event.date,
      );

      debugPrint(
        '🕌 PRAYER TIMES UPDATED FOR SELECTED DATE',
      );

      // ----------------------------------------------------------
      // UPDATE STATE
      // ----------------------------------------------------------

      emit(
        currentState.copyWith(
          selectedDate: selectedHijriDate,
          prayerTimes: prayerTimes,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ HIJRI SELECT DATE ERROR: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      emit(
        HijriCalendarError(
          'حدث خطأ أثناء تحميل مواقيت الصلاة: $e',
        ),
      );
    }
  }

  // ============================================================
  // NEXT HIJRI MONTH
  // ============================================================

  Future<void> _onNextMonth(
      NextHijriMonth event,
      Emitter<HijriCalendarState> emit,
      ) async {
    final currentState = state;

    if (currentState is! HijriCalendarLoaded) {
      return;
    }

    int month = currentState.month + 1;
    int year = currentState.year;

    if (month > 12) {
      month = 1;
      year++;
    }

    debugPrint(
      '➡️ NEXT HIJRI MONTH | '
          'month=$month | '
          'year=$year',
    );

    final dates = getHijriMonth(
      year: year,
      month: month,
    );

    emit(
      currentState.copyWith(
        dates: dates,
        year: year,
        month: month,
        selectedDate: dates.isNotEmpty
            ? dates.first
            : null,
        prayerTimes: null,
      ),
    );
  }

  // ============================================================
  // PREVIOUS HIJRI MONTH
  // ============================================================

  Future<void> _onPreviousMonth(
      PreviousHijriMonth event,
      Emitter<HijriCalendarState> emit,
      ) async {
    final currentState = state;

    if (currentState is! HijriCalendarLoaded) {
      return;
    }

    int month = currentState.month - 1;
    int year = currentState.year;

    if (month < 1) {
      month = 12;
      year--;
    }

    debugPrint(
      '⬅️ PREVIOUS HIJRI MONTH | '
          'month=$month | '
          'year=$year',
    );

    final dates = getHijriMonth(
      year: year,
      month: month,
    );

    emit(
      currentState.copyWith(
        dates: dates,
        year: year,
        month: month,
        selectedDate: dates.isNotEmpty
            ? dates.first
            : null,
        prayerTimes: null,
      ),
    );
  }

  // ============================================================
  // GET SAVED LOCATION
  // ============================================================

  Future<Map<String, double>> _getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();

    const locationModeKey =
        'prayer_location_mode';

    const locationModeAuto = 'auto';
    const locationModeManual = 'manual';

    final mode =
        prefs.getString(locationModeKey) ??
            locationModeAuto;

    debugPrint(
      '📍 HIJRI LOCATION MODE = $mode',
    );

    // ============================================================
    // MANUAL LOCATION
    // ============================================================

    if (mode == locationModeManual) {
      final latitude =
          prefs.getDouble(
            'prayer_manual_latitude',
          ) ??
              30.0444;

      final longitude =
          prefs.getDouble(
            'prayer_manual_longitude',
          ) ??
              31.2357;

      debugPrint(
        '📍 HIJRI LOCATION | MANUAL | '
            'lat=$latitude | '
            'lng=$longitude',
      );

      return {
        'latitude': latitude,
        'longitude': longitude,
      };
    }

    // ============================================================
    // CURRENT GPS LOCATION
    // ============================================================

    final latitude =
        prefs.getDouble(
          'prayer_last_latitude',
        ) ??
            30.0444;

    final longitude =
        prefs.getDouble(
          'prayer_last_longitude',
        ) ??
            31.2357;

    debugPrint(
      '📍 HIJRI LOCATION | CURRENT | '
          'lat=$latitude | '
          'lng=$longitude',
    );

    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}