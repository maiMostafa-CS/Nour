import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:islamic_app/features/locations/presentation/bloc/blocEvent.dart';

import 'package:islamic_app/splashscreen.dart';
import '../../features/adhan_settings/presentation/bloc/adhan_settings_bloc.dart';
import '../../features/adhan_settings/presentation/bloc/adhan_settings_event.dart';
import '../../features/adhan_settings/presentation/pages/adhan_settings_page.dart';
import '../../features/adhan_sound/domain/use_cases/get_adhans_for_prayer.dart';
import '../../features/adhan_sound/domain/use_cases/get_selected_adhan.dart';
import '../../features/adhan_sound/domain/use_cases/save_selected_adhan.dart';
import '../../features/adhan_sound/presentation/bloc/adhan_bloc.dart';
import '../../features/adhan_sound/presentation/bloc/adhan_event.dart';
import '../../features/adhan_sound/presentation/pages/adhan_reciter_page.dart';
import '../../features/hijri_calendar/presentation/bloc/hijri_calendar_bloc.dart';
import '../../features/hijri_calendar/presentation/bloc/hijri_calendar_event.dart';
import '../../features/hijri_calendar/presentation/pages/hijri_calendar_page.dart';

import '../../features/home/presentation/bloc/home_event.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/widget/mainPage.dart';
import '../../features/iqama_setting/presentation/bloc/iqama_settings_bloc.dart';
import '../../features/home/presentation/bloc/bloc.dart';
import '../../features/iqama_setting/presentation/bloc/iqama_settings_event.dart';
import '../../features/iqama_setting/presentation/pages/iqama_settings_page.dart';
import '../../features/locations/presentation/bloc/bloc.dart';
import '../../features/locations/presentation/pages/locationPage.dart';
import '../../features/prayer_settings/presentation/pages/prayer_settings_page.dart';
import '../../features/qibla/presentation/pages/qibla_page.dart';
import '../../features/quran/presentation/pages/quran_page.dart';
import '../../features/tasbih/presentation/pages/tasbih_screen.dart';
import '../../injection_container.dart';
import '../services/prayer_scheduler_split/prayer_scheduler/data/datasources/prayer_notification_local_data_source_impl.dart';

final getIt = GetIt.instance;

class AppRouter {
  static const home = '/';
  static const quran = '/quran';
  static const adhkar = '/adhkar';
  static const splashScreen = '/splashScreen';
  static const qibla = '/qibla';
  static const hijriCalendar = '/hijriCalendar';
static const locationPage = '/locationPage';
static const adhan= "/adhan";
  static const adhanSetting= "/adhanSetting";
static const iqamaSettings= "/iqamaSettings";
  static const prayerSettingsPage= "/prayerSettingsPage";
  static const quranHomePage= "/quranHomePage";
  static const tasbih= "/tasbih";


  static Route<dynamic> onGenerateRoute(
      RouteSettings settings,
      ) {
    switch (settings.name) {
      case quran:
        return MaterialPageRoute(
          builder: (_) => const QuranIndexPage(),
        );


      case tasbih:
        return MaterialPageRoute(
          builder: (_) => const TasbihScreen(),
        );

      case splashScreen:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case qibla:
        return MaterialPageRoute(
          builder: (_) => const QiblaPage(),
        );
      case  prayerSettingsPage :
        return MaterialPageRoute(
          builder: (_) => const PrayerSettingsPage(),
        );
      case hijriCalendar:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<HijriCalendarBloc>()
              ..add(
                const LoadHijriCalendar(),
              ),
            child: const HijriCalendarPage(),
          ),
        );

      case locationPage :
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<LocationBloc>()
              ..add(
                const LoadLocations() ,
              ),
            child: const LocationPage(),
          ),
        );
      case adhan:
        final prayerName = settings.arguments as String?;

        if (prayerName == null || prayerName.isEmpty) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('لم يتم تحديد الصلاة'),
              ),
            ),
          );
        }

        final prayerTitle = switch (prayerName) {
          'fajr' => 'الفجر',
          'dhuhr' => 'الظهر',
          'asr' => 'العصر',
          'maghrib' => 'المغرب',
          'isha' => 'العشاء',
          _ => 'الأذان',
        };

        return MaterialPageRoute(
          builder: (_) => BlocProvider<AdhanBloc>(
            create: (_) => AdhanBloc(
              prayerName: prayerName,
              getAdhansForPrayer: sl<GetAdhansForPrayer>(),
              getSelectedAdhan: sl<GetSelectedAdhan>(),
              saveSelectedAdhan: sl<SaveSelectedAdhan>(),
              prayerScheduler: sl<PrayerNotificationLocalDataSourceImpl>(),
            )..add(const LoadAdhanReciters()),
            child: AdhanReciterPage(
              prayerName: prayerName,
              prayerTitle: prayerTitle,
            ),
          ),
        );
      case adhanSetting:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<AdhanSettingsBloc>(
            create: (_) => sl<AdhanSettingsBloc>()
              ..add(const LoadAdhanSettings()),
            child: const AdhanSettingsPage(),
          ),
        );
      case iqamaSettings:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<IqamaSettingsBloc>(
            create: (_) => sl<IqamaSettingsBloc>()
              ..add(
                const LoadIqamaSettings(),
              ),
            child: const IqamaSettingsPage(),
          ),
        );


      case home:
      default:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<LocationBloc>(
                create: (_) => getIt<LocationBloc>(),
              ),
              BlocProvider<HomeBloc>(
                create: (_) => getIt<HomeBloc>()
                  ..add(const LoadHome()),
              ),
            ],
            child: const MainPage(),
          ),
        );
    }
  }
}