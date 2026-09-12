import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../../../features/adhan/data/datasources/adhan_local_data_source.dart';
import '../../../../features/adhan_settings/domain/repositories/ adhan_settings_repository.dart';
import '../../../../features/iqama_setting/domain/repositories/iqama_settings_repository.dart';
import '../../../../features/prayer_times/data/datasources/prayer_local_data_source.dart';
import '../../../../features/prayer_times/domain/entities/prayer_times_entity.dart';
import '../../../../injection_container.dart';
import 'config/prayer_scheduler_config.dart';
import 'data/datasources/prayer_notification_local_data_source_impl.dart';
import 'notifications/countdown_notification_service.dart';
import 'background/prayer_background_callbacks.dart';

/// عدد الأيام اللي بنحافظ على جدولتها قدام دايماً (rolling window).
const int kPrayerNotificationWindowDays = 4;
const int kPrayerMaintenanceAlarmId = 909001;

class AdhanSchedulerService {
  static final AdhanSchedulerService instance =
  AdhanSchedulerService._internal();

  AdhanSchedulerService._internal();

  factory AdhanSchedulerService() => instance;

  bool _ringingListenerRegistered = false;
  PrayerNotificationLocalDataSourceImpl?
  _notificationDataSource;
  bool _autoRenewRunning = false;

  PrayerNotificationLocalDataSourceImpl get _dataSource {
    return _notificationDataSource ??=
        PrayerNotificationLocalDataSourceImpl(
          prayerCalculator: PrayerLocalDataSourceImpl(),
          adhanSettingsRepository: sl<AdhanSettingsRepository>(),
          iqamaSettingsRepository: sl<IqamaSettingsRepository>(),
          adhanLocalDataSource: sl<AdhanLocalDataSource>(),
        );
  }
  Future<void> showNextPrayerCountdown(
      PrayerTimesEntity prayerTimes,
      ) async {
    prayerSchedulerLog(
      '🔔 Compatibility: showNextPrayerCountdown()',
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
    ];

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      prayerNotificationWindowPrefsKey,
      jsonEncode(entries),
    );

    await CountdownNotificationService.showNextPrayerCountdown();
  }

  /// يجدول نافذة [kPrayerNotificationWindowDays] يوم (بدل 30 يوم زي الأول).
  /// نافذة قصيرة + auto-renew أحسن من نافذة طويلة، لأنها بتحدّث نفسها
  /// من إحداثيات جديدة أول بأول من غير ما تحمل جدولة قديمة لشهر كامل.
  Future<void> schedulePrayerAdhan(
      PrayerTimesEntity prayerTimes, {
        required double latitude,
        required double longitude,
      }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(prayerLastLatitudePrefsKey, latitude);
    await prefs.setDouble(prayerLastLongitudePrefsKey, longitude);

    // ❌ احذف السطرين دول:
    // final calculator = PrayerLocalDataSourceImpl();
    // final dataSource = PrayerNotificationLocalDataSourceImpl(prayerCalculator: calculator);

    // ✅ واستخدم بدالهم الـ singleton المشترك:
    await _dataSource.ensureWindowScheduled(
    latitude: latitude,
    longitude: longitude,
    days: kPrayerNotificationWindowDays,
    );
    }

  Future<void> cancelAdhans() async {
    // ❌ نفس الحاجة هنا
    // final calculator = PrayerLocalDataSourceImpl();
    // final dataSource = PrayerNotificationLocalDataSourceImpl(prayerCalculator: calculator);

    // ✅
    await _dataSource.cancelAll();
  }

  Future<void> cancelAll() async {
    // ✅ استخدم _dataSource هنا كمان بدل instance جديدة
    await _dataSource.cancelAll();

  }

  /// إعادة جدولة كل إشعارات الصلاة بعد تغيير إعدادات الإقامة
  /// أو أي إعداد يؤثر على الجدولة.
  ///
  /// تعتمد على آخر إحداثيات محفوظة في SharedPreferences.
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

      final latitude =
      prefs.getDouble(prayerLastLatitudePrefsKey);

      final longitude =
      prefs.getDouble(prayerLastLongitudePrefsKey);

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

      // 1️⃣ إلغاء الجدول القديم بالكامل
      await _dataSource.cancelAll();

      prayerSchedulerLog(
        '🛑 OLD PRAYER SCHEDULE CANCELLED',
      );

      // 2️⃣ إعادة بناء جدول الـ 4 أيام
      // _dataSource يستخدم repositories الحالية،
      // ومنها IqamaSettingsRepository، وبالتالي
      // سيقرأ القيمة الجديدة التي تم حفظها للتو.
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

  // Future<void> cancelAdhans() async {
  //   final calculator = PrayerLocalDataSourceImpl();
  //
  //   final dataSource =
  //   PrayerNotificationLocalDataSourceImpl(
  //     prayerCalculator: calculator,
  //   );
  //
  //   await dataSource.cancelAll();
  // }

  Future<void> cancelCountdown() async {
    final notifications =
    FlutterLocalNotificationsPlugin();

    await notifications.cancel(
      id: countdownNotificationId,
    );
  }
  // Future<void> cancelAll() async {
  //   final calculator = PrayerLocalDataSourceImpl();
  //
  //   final dataSource =
  //   PrayerNotificationLocalDataSourceImpl(
  //     prayerCalculator: calculator,
  //   );
  //
  //   await dataSource.cancelAll();
  //
  //   final notifications =
  //   FlutterLocalNotificationsPlugin();
  //
  //   await notifications.cancelAll();
  // }

  /// نقطة الدخول الحقيقية لـ "auto-renew": بتتسجل مرة واحدة بس (عادةً
  /// من initialize()) وبتفضل شغالة طول عمر الـ isolate — بما فيه
  /// الـ isolate اللي بيفتحه Foreground Service بتاع الـ alarm package
  /// وقت ما أي Alarm يرن، حتى لو التطبيق نفسه مقفول من وجهة نظر المستخدم.
  ///
  /// كل ما أي أذان/تنبيه/إقامة يرن، بتقرا آخر إحداثيات محفوظة وتنادي
  /// onAlarmFired عشان تمد النافذة يوم زيادة لو محتاجة.
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
              prayerSchedulerLog('⚠️ Reminder auto-stop failed | id=${alarm.id} | $e');
            }
          });
        }
      }
    });

    prayerSchedulerLog('✅ Alarm listener registered (no auto-reschedule while ringing)');
  }

  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // ============================================================
    // 1️⃣ Timezone
    // ============================================================

    tz.initializeTimeZones();

    try {
      final timezoneInfo =
      await FlutterTimezone.getLocalTimezone();

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

    try {
      await Alarm.init();

      prayerSchedulerLog(
        '✅ Alarm.init() completed',
      );
    } catch (e) {
      prayerSchedulerLog(
        '⚠️ Alarm.init(): $e',
      );
    }

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

    final notifications =
    FlutterLocalNotificationsPlugin();

    const androidSettings =
    AndroidInitializationSettings(
      notificationIcon,
    );

    const initializationSettings =
    InitializationSettings(
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

    final androidPlugin =
    notifications
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
    // 7️⃣ Countdown Channel
    // ============================================================

    const countdownChannel =
    AndroidNotificationChannel(
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
    // مهم جدًا:
    // لازم يتسجل بعد Alarm.init()
    // وقبل أي جدولة فعلية.
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
