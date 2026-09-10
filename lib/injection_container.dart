import 'package:get_it/get_it.dart';

import 'core/services/prayer_scheduler_split/prayer_scheduler/data/datasources/prayer_notification_local_data_source.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/data/datasources/prayer_notification_local_data_source_impl.dart';
import 'features/hijri_calendar/data/datasources/hijri_calendar_local_data_source.dart';
import 'features/hijri_calendar/data/repositories/hijri_calendar_repository_impl.dart';
import 'features/hijri_calendar/domain/repositories/hijri_calendar_repository.dart';
import 'features/hijri_calendar/domain/usecases/get_hijri_date.dart';
import 'features/hijri_calendar/domain/usecases/get_hijri_month.dart';
import 'features/hijri_calendar/presentation/bloc/hijri_calendar_bloc.dart';

import 'features/locations/data/datasources/current_location_data_source.dart';
import 'features/locations/data/datasources/location_local_data_source.dart';
import 'features/locations/data/repositories/current_location_repository_impl.dart';
import 'features/locations/data/repositories/location_repository_impl.dart';
import 'features/locations/domain/repositories/current_location_repository.dart';
import 'features/locations/domain/repositories/location_repository.dart';
import 'features/locations/domain/usecase/get_all_locations.dart';
import 'features/locations/domain/usecase/get_cities.dart';
import 'features/locations/domain/usecase/get_city_by_coordinates.dart';
import 'features/locations/domain/usecase/get_current_location.dart';
import 'features/locations/presentation/bloc/bloc.dart';
import 'features/prayer_times/data/datasources/calculateNext30Days.dart';
import 'features/prayer_times/data/datasources/prayer_local_data_source.dart';
import 'features/prayer_times/data/models/SchedulePrayerNotificationsParams.dart';
import 'features/prayer_times/data/repositories/prayer_repository_impl.dart';
import 'features/prayer_times/data/repositories/prayer_times_repository_impl.dart';
import 'features/prayer_times/domain/repositories/PrayerTimesRepository.dart';
import 'features/prayer_times/domain/repositories/prayer_repository.dart';
import 'features/prayer_times/domain/usecases/CancelPrayerNotifications.dart';
import 'features/prayer_times/domain/usecases/ReschedulePrayerNotifications.dart';
import 'features/prayer_times/domain/usecases/get_prayer_times.dart';
import 'features/prayer_times/presentation/bloc/prayer_bloc.dart';

import 'features/qibla/data/datasources/qibla_calculator.dart';
import 'features/qibla/data/repository/qibla_repository_impl.dart';
import 'features/qibla/domain/repositories/qibla_repository.dart';
import 'features/qibla/domain/usecases/get_qibla_direction.dart';
import 'features/qibla/presentation/bloc/bloc.dart';

import 'features/quran/data/datasources/quran_local_data_source.dart';
import 'features/quran/data/repositories/quran_repository_impl.dart';
import 'features/quran/domain/repositories/quran_repository.dart';
import 'features/quran/domain/usecases/get_surahs.dart';
import 'features/quran/presentation/bloc/quran_bloc.dart';

import 'features/adhkar/data/datasources/adhkar_local_data_source.dart';
import 'features/adhkar/data/repositories/adhkar_repository_impl.dart';
import 'features/adhkar/domain/repositories/adhkar_repository.dart';
import 'features/adhkar/domain/usecases/get_adhkar.dart';
import 'features/adhkar/presentation/bloc/adhkar_bloc.dart';


final sl = GetIt.instance;

Future<void> configureDependencies() async {

  // ============================================================
  // Prayer Times
  // ============================================================

  sl.registerLazySingleton<PrayerLocalDataSource>(
        () => PrayerLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<PrayerRepository>(
        () => PrayerRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<GetPrayerTimes>(
        () => GetPrayerTimes(sl()),
  );

  sl.registerFactory<PrayerBloc>(
        () => PrayerBloc(sl()),
  );


  // ============================================================
  // Quran
  // ============================================================

  sl.registerLazySingleton<QuranLocalDataSource>(
        () => QuranLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<QuranRepository>(
        () => QuranRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<GetSurahs>(
        () => GetSurahs(sl()),
  );

  sl.registerFactory<QuranBloc>(
        () => QuranBloc(sl()),
  );


  // ============================================================
  // Adhkar
  // ============================================================

  sl.registerLazySingleton<AdhkarLocalDataSource>(
        () => AdhkarLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<AdhkarRepository>(
        () => AdhkarRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<GetAdhkar>(
        () => GetAdhkar(sl()),
  );

  sl.registerFactory<AdhkarBloc>(
        () => AdhkarBloc(sl()),
  );


  // ============================================================
  // Qibla
  // ============================================================

  sl.registerLazySingleton<QiblaLocalDataSource>(
        () => QiblaLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<QiblaRepository>(
        () => QiblaRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<GetQiblaDirection>(
        () => GetQiblaDirection(sl()),
  );

  sl.registerFactory<QiblaBloc>(
        () => QiblaBloc(sl()),
  );


  // ============================================================
  // Hijri Calendar
  // ============================================================

  sl.registerLazySingleton<HijriCalendarLocalDataSource>(
        () => HijriCalendarLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<HijriCalendarRepository>(
        () => HijriCalendarRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<GetHijriDate>(
        () => GetHijriDate(
      sl(),
    ),
  );

  sl.registerLazySingleton<GetHijriMonth>(
        () => GetHijriMonth(
      sl(),
    ),
  );

  sl.registerFactory<HijriCalendarBloc>(
        () => HijriCalendarBloc(
      getHijriDate: sl(),
      getHijriMonth: sl(),
      getPrayerTimes: sl(),
    ),
  );


  // ============================================================
  // Prayer Notifications (30-day background adhan scheduling)
  // ============================================================

  sl.registerLazySingleton<PrayerNotificationLocalDataSource>(
        () => PrayerNotificationLocalDataSourceImpl(
      prayerCalculator: sl<PrayerLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<PrayerNotificationRepository>(
        () => PrayerNotificationRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<SchedulePrayerNotifications>(
        () => SchedulePrayerNotifications(sl()),
  );

  sl.registerLazySingleton<CancelPrayerNotifications>(
        () => CancelPrayerNotifications(sl()),
  );

  sl.registerLazySingleton<ReschedulePrayerNotifications>(
        () => ReschedulePrayerNotifications(sl()),
  );

  sl.registerFactory<PrayerNotificationBloc>(
        () => PrayerNotificationBloc(
      scheduleNotifications: sl(),
      rescheduleNotifications: sl(),
      cancelNotifications: sl(),
    ),
  );


// ===============================
// Data sources
// ===============================

  sl.registerLazySingleton<LocationLocalDataSource>(
    LocationLocalDataSourceImpl.new,
  );

  sl.registerLazySingleton<CurrentLocationDataSource>(
    CurrentLocationDataSourceImpl.new,
  );


// ===============================
// Repositories
// ===============================

// Manual country / city locations
  sl.registerLazySingleton<LocationRepository>(
        () => LocationRepositoryImpl(
      localDataSource: sl<LocationLocalDataSource>(),
    ),
  );

// Current GPS location
  sl.registerLazySingleton<CurrentLocationRepository>(
        () => CurrentLocationRepositoryImpl(
      dataSource: sl<CurrentLocationDataSource>(),
    ),
  );


// ===============================
// Use cases
// ===============================

  sl.registerLazySingleton<GetAllLocations>(
        () => GetAllLocations(
      sl<LocationRepository>(),
    ),
  );

  sl.registerLazySingleton<GetCitiesByCountry>(
        () => GetCitiesByCountry(
      sl<LocationRepository>(),
    ),
  );

  sl.registerLazySingleton<GetLocationByCity>(
        () => GetLocationByCity(
      sl<LocationRepository>(),
    ),
  );

  sl.registerLazySingleton<GetCurrentLocationUseCase>(
        () => GetCurrentLocationUseCase(
      repository: sl<CurrentLocationRepository>(),
    ),
  );


// ===============================
// BLoC
// ===============================

  sl.registerFactory<LocationBloc>(
        () => LocationBloc(
      getAllLocations: sl<GetAllLocations>(),
      getCitiesByCountry: sl<GetCitiesByCountry>(),
      getLocationByCity: sl<GetLocationByCity>(),
      getCurrentLocation: sl<GetCurrentLocationUseCase>(),
    ),
  );
  }
