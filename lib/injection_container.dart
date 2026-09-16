import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/adhan_scheduler_service.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/data/datasources/prayer_notification_local_data_source.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/data/datasources/prayer_notification_local_data_source_impl.dart';
import 'features/adhan/data/datasources/adhan_local_data_source.dart';
import 'features/adhan/data/repositories/adhan_repository_impl.dart';
import 'features/adhan/domain/usecases/get_adhans.dart';
import 'features/adhan/domain/usecases/get_selected_adhan.dart';
import 'features/adhan/domain/usecases/save_selected_adhan.dart';
import 'features/adhan/domain/repositories/adhan_repository.dart';
import 'features/adhan/presentation/bloc/adhan_bloc.dart';
import 'features/adhan_settings/data/ datasources/adhan_settings_local_data_source.dart';
import 'features/adhan_settings/data/repositories/adhan_settings_repository_impl.dart';
import 'features/adhan_settings/domain/repositories/ adhan_settings_repository.dart';
import 'features/adhan_settings/domain/usecases/get_adhan_settings.dart';
import 'features/adhan_settings/domain/usecases/update_adhan_setting.dart';
import 'features/adhan_settings/presentation/bloc/adhan_settings_bloc.dart';
import 'features/hijri_calendar/data/datasources/hijri_calendar_local_data_source.dart';
import 'features/hijri_calendar/data/repositories/hijri_calendar_repository_impl.dart';
import 'features/hijri_calendar/domain/repositories/hijri_calendar_repository.dart';
import 'features/hijri_calendar/domain/usecases/get_hijri_date.dart';
import 'features/hijri_calendar/domain/usecases/get_hijri_month.dart';
import 'features/hijri_calendar/presentation/bloc/hijri_calendar_bloc.dart';

import 'features/home/presentation/bloc/bloc.dart';
import 'features/iqama_setting/data/datasources/iqama_settings_local_data_source.dart';
import 'features/iqama_setting/data/repositories/iqama_settings_repository_impl.dart';
import 'features/iqama_setting/domain/repositories/iqama_settings_repository.dart';
import 'features/iqama_setting/domain/usecases/get_iqama_settings.dart';
import 'features/iqama_setting/domain/usecases/update_iqama_setting.dart';
import 'features/iqama_setting/presentation/bloc/iqama_settings_bloc.dart';
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



import 'features/adhkar/data/datasources/adhkar_local_data_source.dart';
import 'features/adhkar/data/repositories/adhkar_repository_impl.dart';
import 'features/adhkar/domain/repositories/adhkar_repository.dart';
import 'features/adhkar/domain/usecases/get_adhkar.dart';
import 'features/adhkar/presentation/bloc/adhkar_bloc.dart';
import 'features/quran/data/datasources/quran_local_data_source.dart';
import 'features/quran/data/repositories/quran_repository_impl.dart';
import 'features/quran/domain/repositories/quran_repository.dart';
import 'features/quran/domain/usecases/get_page.dart';
import 'features/quran/domain/usecases/get_surahs.dart';
import 'features/quran/presentation/bloc/quran_bloc.dart';




final sl = GetIt.instance;

Future<void> configureDependencies() async {

  // sl.registerFactory<HomeBloc>(
  //       () => HomeBloc(),
  // );
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

  sl.registerLazySingleton<PrayerNotificationLocalDataSourceImpl>(
        () => PrayerNotificationLocalDataSourceImpl(
      prayerCalculator: sl<PrayerLocalDataSource>(),
      adhanSettingsRepository: sl<AdhanSettingsRepository>(),
      iqamaSettingsRepository: sl<IqamaSettingsRepository>(),
      adhanLocalDataSource: sl<AdhanLocalDataSource>(),
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
  final prefs = await SharedPreferences.getInstance();

  sl.registerFactory<LocationBloc>(
        () => LocationBloc(
      getAllLocations: sl<GetAllLocations>(),
      getCitiesByCountry: sl<GetCitiesByCountry>(),
      getLocationByCity: sl<GetLocationByCity>(),
      getCurrentLocation: sl<GetCurrentLocationUseCase>(),
    ),
  );
// ============================================================
// SharedPreferences
// ============================================================


  sl.registerLazySingleton<SharedPreferences>(
        () => prefs,
  );


// ============================================================
// Adhan
// ============================================================

  sl.registerLazySingleton<AdhanLocalDataSource>(
        () => AdhanLocalDataSourceImpl(
      prefs: prefs,
    ),
  );

  sl.registerLazySingleton<AdhanRepository>(
        () => AdhanRepositoryImpl(
      localDataSource: sl<AdhanLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetAdhans>(
        () => GetAdhans(
      sl<AdhanRepository>(),
    ),
  );

  sl.registerLazySingleton<GetSelectedAdhan>(
        () => GetSelectedAdhan(
      sl<AdhanRepository>(),
    ),
  );

  sl.registerLazySingleton<SaveSelectedAdhan>(
        () => SaveSelectedAdhan(
      sl<AdhanRepository>(),
    ),
  );

  sl.registerFactory<AdhanBloc>(
        () => AdhanBloc(
      getAdhans: sl<GetAdhans>(),
      getSelectedAdhan: sl<GetSelectedAdhan>(),
      saveSelectedAdhan: sl<SaveSelectedAdhan>(),
      prayerScheduler: sl<PrayerNotificationLocalDataSourceImpl>(),
    ),
  );
// Data Source
  sl.registerLazySingleton<AdhanSettingsLocalDataSource>(
        () => AdhanSettingsLocalDataSourceImpl(
      prefs: sl<SharedPreferences>(),
    ),
  );

// Repository
  sl.registerLazySingleton<AdhanSettingsRepository>(
        () => AdhanSettingsRepositoryImpl(
      localDataSource: sl<AdhanSettingsLocalDataSource>(),
    ),
  );

// UseCases

  sl.registerLazySingleton<GetAdhanSettings>(
        () => GetAdhanSettings(repository: sl<AdhanSettingsRepository>()),
  );

  sl.registerLazySingleton<UpdateAdhanSetting>(
        () => UpdateAdhanSetting(repository: sl<AdhanSettingsRepository>()),
  );

// Bloc
  sl.registerFactory<AdhanSettingsBloc>(
        () => AdhanSettingsBloc(
      getAdhanSettings: sl<GetAdhanSettings>(),
      updateAdhanSetting: sl<UpdateAdhanSetting>(),
      prayerScheduler: sl<PrayerNotificationLocalDataSourceImpl>(),
    ),
  );
  sl.registerLazySingleton<IqamaSettingsLocalDataSource>(
        () => IqamaSettingsLocalDataSourceImpl(
      prefs: sl<SharedPreferences>(),
    ),
  );

  sl.registerLazySingleton<IqamaSettingsRepository>(
        () => IqamaSettingsRepositoryImpl(
      localDataSource:
      sl<IqamaSettingsLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetIqamaSettings>(
        () => GetIqamaSettings(
      repository:
      sl<IqamaSettingsRepository>(),
    ),
  );

  sl.registerLazySingleton<UpdateIqamaSetting>(
        () => UpdateIqamaSetting(
      repository:
      sl<IqamaSettingsRepository>(),
    ),
  );

  sl.registerFactory<IqamaSettingsBloc>(
        () => IqamaSettingsBloc(
      getIqamaSettings:
      sl<GetIqamaSettings>(),
      updateIqamaSetting:
      sl<UpdateIqamaSetting>(),
    ),
  );


  sl.registerLazySingleton<AdhanSchedulerService>(
        () => AdhanSchedulerService(),
  );
  sl.registerFactory<HomeBloc>(
        () => HomeBloc(
      prefs: sl<SharedPreferences>(),
      getCurrentLocation: sl<GetCurrentLocationUseCase>(),
      getPrayerTimes: sl<GetPrayerTimes>(),
      scheduler: sl<AdhanSchedulerService>(),
    ),
  );


  // Bloc
// ============================================================
// QURAN
// ============================================================

// DataSource
  sl.registerLazySingleton<QuranPagesDataSource>(
        () => QuranPagesDataSourceImpl(),
  );

// Repository
  sl.registerLazySingleton<QuranRepository>(
        () => QuranRepositoryImpl(
      sl<QuranPagesDataSource>(),
    ),
  );

// UseCases
  sl.registerLazySingleton<GetSurahs>(
        () => GetSurahs(
      sl<QuranRepository>(),
    ),
  );

  sl.registerLazySingleton<GetPage>(
        () => GetPage(
      sl<QuranRepository>(),
    ),
  );

// Bloc
  sl.registerFactory<QuranBloc>(
        () => QuranBloc(
      getSurahs: sl<GetSurahs>(),
      getPage: sl<GetPage>(),
    ),
  );

  }
