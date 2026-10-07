import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:islamic_app/core/services/prayer_scheduler_split/prayer_scheduler/services/adhan_asset_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../../features/adhan_settings/domain/repositories/adhan_settings_repository.dart';
import '../../../../features/adhan_sound/data/datasources/adhan_local_data_source.dart';
import '../../../../features/iqama_setting/domain/repositories/iqama_settings_repository.dart';
import '../../../../features/prayer_times/data/datasources/prayer_local_data_source.dart';
import '../../../../features/prayer_times/domain/entities/prayer_times_entity.dart';
import '../../../../injection_container.dart';
import '../../alarm_cleanup/alarm_id_tracker.dart';
import 'background/prayer_background_callbacks.dart';
import 'config/prayer_scheduler_config.dart';
import 'data/datasources/prayer_notification_local_data_source_impl.dart';
import 'notifications/countdown_notification_service.dart';
/// Number of days always kept scheduled ahead (rolling window).
const int kPrayerNotificationWindowDays = 4;
const int kPrayerMaintenanceAlarmId = 909001;

class AdhanSchedulerService {
  // ❌ Delete this line
  // final AlarmIdTracker _alarmIdTracker;

  static final AdhanSchedulerService instance =
  AdhanSchedulerService._internal();

  AdhanSchedulerService._internal();

  factory AdhanSchedulerService() => instance;

  bool _ringingListenerRegistered = false;

  static bool _alarmInitialized = false;
  static Future<void>? _alarmInitFuture;

  /// Initializes the `alarm` plugin exactly once per isolate.
  /// Must be awaited before any Alarm.set / Alarm.getAlarm call.
  static Future<void> ensureAlarmInitialized() {
    if (_alarmInitialized) return Future.value();
    return _alarmInitFuture ??= () async {
      try {
        await Alarm.init();
        _alarmInitialized = true;
        prayerSchedulerLog('✅ Alarm.init() completed');
      } catch (e) {
        _alarmInitFuture = null;
        prayerSchedulerLog('⚠️ Alarm.init(): $e');
      }
    }();
  }
  PrayerNotificationLocalDataSourceImpl? _notificationDataSource;
  AdhanAssetProvider? _adhanAssetProvider;

  AdhanAssetProvider get adhanAssetProvider =>
      _adhanAssetProvider ??= AdhanAssetProvider(
        localDataSource: sl<AdhanLocalDataSource>(),
      );

  PrayerNotificationLocalDataSourceImpl get _dataSource {
    return _notificationDataSource ??= PrayerNotificationLocalDataSourceImpl(
      prayerCalculator: PrayerLocalDataSourceImpl(),
      adhanSettingsRepository: sl<AdhanSettingsRepository>(),
      iqamaSettingsRepository: sl<IqamaSettingsRepository>(),
      adhanLocalDataSource: sl<AdhanLocalDataSource>(),
      adhanAssetProvider: adhanAssetProvider,
      alarmIdTracker: sl<AlarmIdTracker>(),  // ← هنا بس
    );
  }

  Future<void> showNextPrayerCountdown(
      PrayerTimesEntity prayerTimes,
      ) async {
    prayerSchedulerLog(
      '🔔 Compatibility: showNextPrayerCountdown()',
    );

    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(prayerLastLatitudePrefsKey) ?? 30.0444;
    final lng = prefs.getDouble(prayerLastLongitudePrefsKey) ?? 31.2357;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowTimes = PrayerLocalDataSourceImpl().calculate(
      latitude: lat,
      longitude: lng,
      date: tomorrow,
    );

    final entries = <Map<String, String>>[
      {
        'name': 'الفجر',
        'time': prayerTimes.fajr.toIso8601String(),
      },
      {
        'name': 'الشروق',
        'time': prayerTimes.sunrise.toIso8601String(),
      },
      {
        'name': 'الظهر',
        'time': prayerTimes.dhuhr.toIso8601String(),
      },
      {
        'name': 'العصر',
        'time': prayerTimes.asr.toIso8601String(),
      },
      {
        'name': 'المغرب',
        'time': prayerTimes.maghrib.toIso8601String(),
      },
      {
        'name': 'العشاء',
        'time': prayerTimes.isha.toIso8601String(),
      },
      {
        'name': 'الفجر',
        'time': tomorrowTimes.fajr.toIso8601String(),
      },
      {
        'name': 'الشروق',
        'time': tomorrowTimes.sunrise.toIso8601String(),
      },
      {
        'name': 'الظهر',
        'time': tomorrowTimes.dhuhr.toIso8601String(),
      },
      {
        'name': 'العصر',
        'time': tomorrowTimes.asr.toIso8601String(),
      },
      {
        'name': 'المغرب',
        'time': tomorrowTimes.maghrib.toIso8601String(),
      },
      {
        'name': 'العشاء',
        'time': tomorrowTimes.isha.toIso8601String(),
      },
    ];

    await prefs.setString(
      prayerNotificationWindowPrefsKey,
      jsonEncode(entries),
    );

    await CountdownNotificationService.showNextPrayerCountdown();
  }

  /// Schedules a [kPrayerNotificationWindowDays]-day window (instead of 30 days as before).
  /// A short window + auto-renew is better than a long window because it updates itself
  /// from fresh coordinates without carrying an outdated month-long schedule.
  Future<void> schedulePrayerAdhan(
      PrayerTimesEntity prayerTimes, {
        required double latitude,
        required double longitude,
      }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(prayerLastLatitudePrefsKey, latitude);
    await prefs.setDouble(prayerLastLongitudePrefsKey, longitude);

    await ensureAlarmInitialized();

    await _dataSource.ensureWindowScheduled(
      latitude: latitude,
      longitude: longitude,
      days: kPrayerNotificationWindowDays,
    );
  }

  Future<void> cancelAdhans() async {
    await _dataSource.cancelAll();
  }

  Future<void> cancelAll() async {
    await _dataSource.cancelAll();
  }

  /// Reschedule all prayer notifications after changing Iqama settings
  /// or any setting that affects scheduling.
  ///
  /// Uses the latest coordinates saved in SharedPreferences.
  Future<void> reschedulePrayerNotifications() async {
    prayerSchedulerLog(
      '════════════════════════════════════',
    );

    prayerSchedulerLog(
      '🔄 RESCHEDULE PRAYER NOTIFICATIONS',
    );

    prayerSchedulerLog(
      '════════════════════════════════════',
    );

    try {
      final prefs = await SharedPreferences.getInstance();

      final latitude = prefs.getDouble(prayerLastLatitudePrefsKey);

      final longitude = prefs.getDouble(prayerLastLongitudePrefsKey);

      prayerSchedulerLog(
        '📍 Saved location: '
            'lat=$latitude | lng=$longitude',
      );

      if (latitude == null || longitude == null) {
        prayerSchedulerLog(
          '⚠️ Cannot reschedule: saved location is missing',
        );

        return;
      }

      await ensureAlarmInitialized();

      // 1️⃣ Cancel the entire old schedule
      await _dataSource.cancelAll();

      prayerSchedulerLog(
        '🛑 OLD PRAYER SCHEDULE CANCELLED',
      );

      // 2️⃣ Rebuild the 4-day schedule
      // _dataSource uses the current repositories,
      // including IqamaSettingsRepository, so
      // it will read the new value that was just saved.
      await _dataSource.ensureWindowScheduled(
        latitude: latitude,
        longitude: longitude,
        days: kPrayerNotificationWindowDays,
      );

      prayerSchedulerLog(
        '✅ PRAYER NOTIFICATIONS RESCHEDULED',
      );

      prayerSchedulerLog(
        '📅 Window = '
            '$kPrayerNotificationWindowDays days',
      );

      prayerSchedulerLog(
        '════════════════════════════════════',
      );
    } catch (e, stackTrace) {
      prayerSchedulerLog(
        '❌ RESCHEDULE PRAYER NOTIFICATIONS FAILED',
      );

      prayerSchedulerLog(
        'Error: $e',
      );

      prayerSchedulerLog(
        'StackTrace: $stackTrace',
      );
    }
  }

  Future<void> cancelCountdown() async {
    final notifications = FlutterLocalNotificationsPlugin();

    await notifications.cancel(
      id: countdownNotificationId,
    );
  }

  /// The actual "auto-renew" entry point: registered only once (usually
  /// from initialize()) and remains active for the lifetime of the isolate — including
  /// the isolate started by the alarm package Foreground Service
  /// when any Alarm rings, even if the app appears closed to the user.
  ///
  /// Whenever an adhan/reminder/iqama rings, it reads the latest saved coordinates and calls
  /// onAlarmFired to extend the window by one day when needed.
  /// Registers the ringing listener once. It only handles reminder cleanup.
  /// Scheduling is intentionally NOT renewed while an alarm is firing, because
  /// cancelling/rebuilding alarms during playback can cancel upcoming prayers.
  void registerAutoRenewListener() {
    if (_ringingListenerRegistered) return;
    _ringingListenerRegistered = true;

    Alarm.ringing.listen((alarmSet) async {
      for (final alarm in alarmSet.alarms) {
        if (alarm.payload == 'reminder_before_adhan') {
          Future.delayed(const Duration(seconds: 15), () async {
            try {
              await Alarm.stop(alarm.id);
              prayerSchedulerLog('🛑 Reminder auto-stopped | id=${alarm.id}');
            } catch (e) {
              prayerSchedulerLog(
                '⚠️ Reminder auto-stop failed | id=${alarm.id} | $e',
              );
            }
          });
        } else if (alarm.payload == 'iqama') {
          Future.delayed(const Duration(seconds: 60), () async {
            try {
              final isRinging = await Alarm.isRinging(alarm.id);
              if (isRinging) {
                await Alarm.stop(alarm.id);
                prayerSchedulerLog('🛑 Iqama auto-stopped after ringing | id=${alarm.id}');
              }
            } catch (e) {
              prayerSchedulerLog(
                '⚠️ Iqama auto-stop failed | id=${alarm.id} | $e',
              );
            }
          });
        }
      }
    });

    prayerSchedulerLog(
      '✅ Alarm listener registered (no auto-reschedule while ringing)',
    );
  }

  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // ============================================================
    // 1️⃣ Timezone
    // ============================================================

    tz.initializeTimeZones();

    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();

      tz.setLocalLocation(
        tz.getLocation(timezoneInfo.identifier),
      );
    } catch (e) {
      prayerSchedulerLog(
        '⚠️ Timezone initialization: $e',
      );
    }

    // ============================================================
    // 2️⃣ Alarm
    // ============================================================

    await ensureAlarmInitialized();

    // ============================================================
    // 3️⃣ Android Alarm Manager
    // ============================================================

    try {
      await AndroidAlarmManager.initialize();

      prayerSchedulerLog(
        '✅ AndroidAlarmManager.initialize() completed',
      );

      await AndroidAlarmManager.periodic(
        const Duration(hours: 12),
        kPrayerMaintenanceAlarmId,
        prayerScheduleMaintenanceCallback,
        exact: false,
        wakeup: true,
        rescheduleOnReboot: true,
      );
      prayerSchedulerLog('✅ Prayer background maintenance scheduled');
    } catch (e) {
      prayerSchedulerLog(
        '⚠️ AndroidAlarmManager.initialize(): $e',
      );
    }

    // ============================================================
    // 4️⃣ Local Notifications
    // ============================================================

    final notifications = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings(
      notificationIcon,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    try {
      await notifications.initialize(
        settings: initializationSettings,
      );

      prayerSchedulerLog(
        '✅ FlutterLocalNotifications.initialize() completed',
      );
    } catch (e) {
      prayerSchedulerLog(
        '⚠️ FlutterLocalNotifications.initialize(): $e',
      );
    }

    final androidPlugin = notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // ============================================================
    // 5️⃣ Notification Permission
    // ============================================================

    try {
      await androidPlugin?.requestNotificationsPermission();
    } catch (e) {
      prayerSchedulerLog(
        '⚠️ Notification permission: $e',
      );
    }

    // ============================================================
    // 6️⃣ Exact Alarm Permission
    // ============================================================

    try {
      await androidPlugin?.requestExactAlarmsPermission();
    } catch (e) {
      prayerSchedulerLog(
        '⚠️ Exact alarm permission: $e',
      );
    }

    // ============================================================
    // 6b️⃣ Full Screen Intent Permission (Android 14+)
    //
    // Android 14 (API 34) يطلب الإذن صراحةً لاستخدام
    // USE_FULL_SCREEN_INTENT — بدونه لن يُعرض الأذان
    // على الشاشة المقفولة.
    // ============================================================

    try {
      await androidPlugin?.requestFullScreenIntentPermission();
      prayerSchedulerLog(
        '✅ Full screen intent permission requested',
      );
    } catch (e) {
      // لو الميثود مش موجودة في الإصدار القديم من المكتبة، نتجاهل
      prayerSchedulerLog(
        '⚠️ Full screen intent permission: $e',
      );
    }

    // ============================================================
    // 7️⃣ Countdown Channel
    // ============================================================

    const countdownChannel = AndroidNotificationChannel(
      countdownChannelId,
      countdownChannelName,
      description: countdownChannelDescription,
      importance: Importance.low,
      playSound: false,
    );

    try {
      await androidPlugin?.createNotificationChannel(
        countdownChannel,
      );
    } catch (e) {
      prayerSchedulerLog(
        '⚠️ Countdown channel: $e',
      );
    }

    // ============================================================
    // 8️⃣ Auto-Renew Listener
    //
    // Very important:
    // It must be registered after Alarm.init()
    // and before any actual scheduling.
    // ============================================================

    registerAutoRenewListener();

    prayerSchedulerLog(
      '🎉 Compatibility initialize() completed',
    );
  }

  Future<void> requestBatteryOptimizationExemption() async {
    prayerSchedulerLog(
      '🔋 Requesting battery optimization exemption...',
    );

    try {
      final status = await Permission.ignoreBatteryOptimizations.status;

      prayerSchedulerLog('🔋 Current status = $status');

      if (!status.isGranted) {
        final result = await Permission.ignoreBatteryOptimizations.request();

        prayerSchedulerLog('🔋 Request result = $result');
      } else {
        prayerSchedulerLog('🔋 Already exempted');
      }
    } catch (e, stackTrace) {
      prayerSchedulerLog('❌ Battery optimization request FAILED: $e');
      prayerSchedulerLog('STACKTRACE: $stackTrace');
    }
  }
}