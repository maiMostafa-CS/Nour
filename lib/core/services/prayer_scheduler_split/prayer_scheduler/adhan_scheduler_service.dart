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
import '../../../../features/prayer_times/data/datasources/prayer_local_data_source.dart';
import '../../../../features/prayer_times/domain/entities/prayer_times_entity.dart';
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
// import 'dart:convert';
//
// import 'package:alarm/alarm.dart';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_timezone/flutter_timezone.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
//
// import '../../../../features/prayer_times/data/datasources/prayer_local_data_source.dart';
// import '../../../../features/prayer_times/domain/entities/prayer_times_entity.dart';
//
// import 'config/prayer_scheduler_config.dart';
// import 'data/datasources/prayer_notification_local_data_source_impl.dart';
// import 'notifications/countdown_notification_service.dart';
// import 'background/prayer_background_callbacks.dart';

// /// عدد الأيام التي نحافظ على جدولتها دائمًا.
// const int kPrayerNotificationWindowDays = 4;
// const int kPrayerMaintenanceAlarmId = 909001;
//
// class AdhanSchedulerService {
//   static final AdhanSchedulerService instance =
//   AdhanSchedulerService._internal();
//
//   AdhanSchedulerService._internal();
//
//   factory AdhanSchedulerService() => instance;
//
//   bool _ringingListenerRegistered = false;
//
//   PrayerNotificationLocalDataSourceImpl? _notificationDataSource;
//
//   /// يمنع تشغيل أكثر من Auto-Renew في نفس الوقت.
//   bool _autoRenewRunning = false;
//
//   PrayerNotificationLocalDataSourceImpl get _dataSource {
//     return _notificationDataSource ??=
//         PrayerNotificationLocalDataSourceImpl(
//           prayerCalculator: PrayerLocalDataSourceImpl(),
//         );
//   }
//
//   // ============================================================
//   // Countdown
//   // ============================================================
//
//   Future<void> showNextPrayerCountdown(
//       PrayerTimesEntity prayerTimes,
//       ) async {
//     prayerSchedulerLog(
//       '🔔 Compatibility: showNextPrayerCountdown()',
//     );
//
//     final entries = <Map<String, String>>[
//       {
//         'name': 'الفجر',
//         'time': prayerTimes.fajr.toIso8601String(),
//       },
//       {
//         'name': 'الظهر',
//         'time': prayerTimes.dhuhr.toIso8601String(),
//       },
//       {
//         'name': 'العصر',
//         'time': prayerTimes.asr.toIso8601String(),
//       },
//       {
//         'name': 'المغرب',
//         'time': prayerTimes.maghrib.toIso8601String(),
//       },
//       {
//         'name': 'العشاء',
//         'time': prayerTimes.isha.toIso8601String(),
//       },
//     ];
//
//     final prefs = await SharedPreferences.getInstance();
//
//     await prefs.setString(
//       prayerNotificationWindowPrefsKey,
//       jsonEncode(entries),
//     );
//
//     await CountdownNotificationService.showNextPrayerCountdown();
//   }
//
//   // ============================================================
//   // Schedule
//   // ============================================================
//
//   Future<void> schedulePrayerAdhan(
//       PrayerTimesEntity prayerTimes, {
//         required double latitude,
//         required double longitude,
//       }) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     await prefs.setDouble(
//       prayerLastLatitudePrefsKey,
//       latitude,
//     );
//
//     await prefs.setDouble(
//       prayerLastLongitudePrefsKey,
//       longitude,
//     );
//
//     prayerSchedulerLog(
//       '📅 schedulePrayerAdhan() '
//           '| lat=$latitude '
//           '| lng=$longitude '
//           '| window=$kPrayerNotificationWindowDays days',
//     );
//
//     await _dataSource.ensureWindowScheduled(
//       latitude: latitude,
//       longitude: longitude,
//       days: kPrayerNotificationWindowDays,
//     );
//   }
//
//   // ============================================================
//   // Cancel Adhans
//   // ============================================================
//
//   Future<void> cancelAdhans() async {
//     prayerSchedulerLog(
//       '🛑 cancelAdhans()',
//     );
//
//     await _dataSource.cancelAll();
//   }
//
//   // ============================================================
//   // Cancel All
//   // ============================================================
//
//   Future<void> cancelAll() async {
//     prayerSchedulerLog(
//       '🛑 cancelAll()',
//     );
//
//     await _dataSource.cancelAll();
//   }
//
//   // ============================================================
//   // Cancel Countdown
//   // ============================================================
//
//   Future<void> cancelCountdown() async {
//     prayerSchedulerLog(
//       '🛑 cancelCountdown()',
//     );
//
//     final notifications =
//     FlutterLocalNotificationsPlugin();
//
//     await notifications.cancel(
//       id: countdownNotificationId,
//     );
//   }
//
//   // ============================================================
//   // AUTO RENEW
//   // ============================================================
//
//   void registerAutoRenewListener() {
//     if (_ringingListenerRegistered) {
//       prayerSchedulerLog(
//         '⏭️ Auto-renew listener already registered',
//       );
//       return;
//     }
//
//     _ringingListenerRegistered = true;
//
//     prayerSchedulerLog(
//       '🔗 Registering Alarm.ringing listener...',
//     );
//
//     Alarm.ringing.listen(
//           (alarmSet) async {
//         // --------------------------------------------------------
//         // 1. Log كل Alarm رن
//         // --------------------------------------------------------
//
//         for (final alarm in alarmSet.alarms) {
//           prayerSchedulerLog(
//             '🔔 RINGING '
//                 '| id=${alarm.id} '
//                 '| dateTime=${alarm.dateTime} '
//                 '| payload=${alarm.payload}',
//           );
//         }
//
//         // --------------------------------------------------------
//         // 2. لو Auto-Renew شغال بالفعل لا نبدأ واحد جديد
//         // --------------------------------------------------------
//
//         if (_autoRenewRunning) {
//           prayerSchedulerLog(
//             '⏸️ Auto-renew skipped: already running',
//           );
//           return;
//         }
//
//         // --------------------------------------------------------
//         // 3. اقرأ حالة الجدولة الحالية
//         // --------------------------------------------------------
//
//         try {
//           final prefs =
//           await SharedPreferences.getInstance();
//
//           final scheduledFrom =
//           prefs.getString(
//             prayerScheduledFromPrefsKey,
//           );
//
//           final scheduledDays =
//           prefs.getInt(
//             prayerScheduledDaysPrefsKey,
//           );
//
//           prayerSchedulerLog(
//             '📊 Current schedule state '
//                 '| from=$scheduledFrom '
//                 '| days=$scheduledDays',
//           );
//
//           // ------------------------------------------------------
//           // لو مفيش Schedule محفوظة، لا نعيد الجدولة من هنا.
//           // ------------------------------------------------------
//
//           if (scheduledFrom == null ||
//               scheduledDays == null ||
//               scheduledDays <= 0) {
//             prayerSchedulerLog(
//               '⏭️ Auto-renew skipped: '
//                   'no valid scheduled window',
//             );
//             return;
//           }
//
//           // ------------------------------------------------------
//           // 4. حساب آخر يوم موجود في الـ Window
//           // ------------------------------------------------------
//
//           final fromDate =
//           DateTime.tryParse(scheduledFrom);
//
//           if (fromDate == null) {
//             prayerSchedulerLog(
//               '⚠️ Auto-renew skipped: '
//                   'invalid scheduledFrom=$scheduledFrom',
//             );
//             return;
//           }
//
//           final now = DateTime.now();
//
//           final lastScheduledDay =
//           DateTime(
//             fromDate.year,
//             fromDate.month,
//             fromDate.day,
//           ).add(
//             Duration(
//               days: scheduledDays - 1,
//             ),
//           );
//
//           final today = DateTime(
//             now.year,
//             now.month,
//             now.day,
//           );
//
//           final daysRemaining =
//               lastScheduledDay
//                   .difference(today)
//                   .inDays;
//
//           prayerSchedulerLog(
//             '📅 Auto-renew calculation '
//                 '| today=$today '
//                 '| last=$lastScheduledDay '
//                 '| remaining=$daysRemaining',
//           );
//
//           // ------------------------------------------------------
//           // IMPORTANT
//           //
//           // لو لسه عندنا يوم كامل أو أكثر في المستقبل،
//           // ممنوع نعمل cancelAll().
//           //
//           // وده يمنع قتل الـ Adhan الموجود.
//           // ------------------------------------------------------
//
//           if (daysRemaining >= 1) {
//             prayerSchedulerLog(
//               '⏭️ Auto-renew skipped: '
//                   'window still has enough days',
//             );
//             return;
//           }
//
//           // ------------------------------------------------------
//           // 5. نحتاج فعلاً لتجديد الـ Window
//           // ------------------------------------------------------
//
//           final lat = prefs.getDouble(
//             prayerLastLatitudePrefsKey,
//           );
//
//           final lng = prefs.getDouble(
//             prayerLastLongitudePrefsKey,
//           );
//
//           if (lat == null || lng == null) {
//             prayerSchedulerLog(
//               '⚠️ Auto-renew skipped: '
//                   'no saved coordinates',
//             );
//             return;
//           }
//
//           _autoRenewRunning = true;
//
//           prayerSchedulerLog(
//             '🔄 AUTO-RENEW START '
//                 '| lat=$lat '
//                 '| lng=$lng',
//           );
//
//           await _dataSource.onAlarmFired(
//             latitude: lat,
//             longitude: lng,
//             days: kPrayerNotificationWindowDays,
//           );
//
//           prayerSchedulerLog(
//             '✅ AUTO-RENEW FINISHED',
//           );
//         } catch (e, stackTrace) {
//           prayerSchedulerLog(
//             '❌ AUTO-RENEW FAILED: $e',
//           );
//
//           prayerSchedulerLog(
//             'STACKTRACE: $stackTrace',
//           );
//         } finally {
//           _autoRenewRunning = false;
//
//           prayerSchedulerLog(
//             '🔓 Auto-renew lock released',
//           );
//         }
//       },
//     );
//
//     prayerSchedulerLog(
//       '✅ Auto-renew listener registered',
//     );
//   }
//
//   // ============================================================
//   // INITIALIZE
//   // ============================================================
//
//   Future<void> initialize() async {
//     WidgetsFlutterBinding.ensureInitialized();
//
//     prayerSchedulerLog(
//       '🚀 AdhanSchedulerService.initialize() START',
//     );
//
//     // ============================================================
//     // 1. Timezone
//     // ============================================================
//
//     tz.initializeTimeZones();
//
//     try {
//       final timezoneInfo =
//       await FlutterTimezone.getLocalTimezone();
//
//       tz.setLocalLocation(
//         tz.getLocation(
//           timezoneInfo.identifier,
//         ),
//       );
//
//       prayerSchedulerLog(
//         '🌍 Timezone = ${timezoneInfo.identifier}',
//       );
//     } catch (e) {
//       prayerSchedulerLog(
//         '⚠️ Timezone initialization failed: $e',
//       );
//     }
//
//     // ============================================================
//     // 2. Alarm
//     // ============================================================
//
//     try {
//       await Alarm.init();
//
//       prayerSchedulerLog(
//         '✅ Alarm.init() completed',
//       );
//     } catch (e) {
//       prayerSchedulerLog(
//         '⚠️ Alarm.init(): $e',
//       );
//     }
//
//     // ============================================================
//     // 3. Android Alarm Manager
//     // ============================================================
//
//     try {
//       await AndroidAlarmManager.initialize();
//
//       prayerSchedulerLog(
//         '✅ AndroidAlarmManager.initialize() completed',
//       );
//     } catch (e) {
//       prayerSchedulerLog(
//         '⚠️ AndroidAlarmManager.initialize(): $e',
//       );
//     }
//
//     // ============================================================
//     // 4. Local Notifications
//     // ============================================================
//
//     final notifications =
//     FlutterLocalNotificationsPlugin();
//
//     const androidSettings =
//     AndroidInitializationSettings(
//       notificationIcon,
//     );
//
//     const initializationSettings =
//     InitializationSettings(
//       android: androidSettings,
//     );
//
//     try {
//       await notifications.initialize(
//         settings: initializationSettings,
//       );
//
//       prayerSchedulerLog(
//         '✅ FlutterLocalNotifications.initialize() completed',
//       );
//     } catch (e) {
//       prayerSchedulerLog(
//         '⚠️ FlutterLocalNotifications.initialize(): $e',
//       );
//     }
//
//     // ============================================================
//     // 5. Notification Permission
//     // ============================================================
//
//     final androidPlugin =
//     notifications
//         .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>();
//
//     try {
//       await androidPlugin?.requestNotificationsPermission();
//
//       prayerSchedulerLog(
//         '✅ Notification permission checked',
//       );
//     } catch (e) {
//       prayerSchedulerLog(
//         '⚠️ Notification permission: $e',
//       );
//     }
//
//     // ============================================================
//     // 6. Exact Alarm Permission
//     // ============================================================
//
//     try {
//       await androidPlugin?.requestExactAlarmsPermission();
//
//       prayerSchedulerLog(
//         '✅ Exact alarm permission checked',
//       );
//     } catch (e) {
//       prayerSchedulerLog(
//         '⚠️ Exact alarm permission: $e',
//       );
//     }
//
//     // ============================================================
//     // 7. Countdown Channel
//     // ============================================================
//
//     const countdownChannel =
//     AndroidNotificationChannel(
//       countdownChannelId,
//       countdownChannelName,
//       description: countdownChannelDescription,
//       importance: Importance.low,
//       playSound: false,
//     );
//
//     try {
//       await androidPlugin?.createNotificationChannel(
//         countdownChannel,
//       );
//
//       prayerSchedulerLog(
//         '✅ Countdown notification channel created',
//       );
//     } catch (e) {
//       prayerSchedulerLog(
//         '⚠️ Countdown channel: $e',
//       );
//     }
//
//     // ============================================================
//     // 8. Auto-Renew Listener
//     // ============================================================
//
//     registerAutoRenewListener();
//
//     prayerSchedulerLog(
//       '🎉 AdhanSchedulerService.initialize() COMPLETED',
//     );
//   }
//
//   // ============================================================
//   // Battery Optimization
//   // ============================================================
//
//   Future<void> requestBatteryOptimizationExemption() async {
//     prayerSchedulerLog(
//       '🔋 Requesting battery optimization exemption...',
//     );
//
//     try {
//       final status =
//       await Permission.ignoreBatteryOptimizations.status;
//
//       prayerSchedulerLog(
//         '🔋 Current status = $status',
//       );
//
//       if (!status.isGranted) {
//         final result =
//         await Permission
//             .ignoreBatteryOptimizations
//             .request();
//
//         prayerSchedulerLog(
//           '🔋 Request result = $result',
//         );
//       } else {
//         prayerSchedulerLog(
//           '🔋 Already exempted',
//         );
//       }
//     } catch (e, stackTrace) {
//       prayerSchedulerLog(
//         '❌ Battery optimization request FAILED: $e',
//       );
//
//       prayerSchedulerLog(
//         'STACKTRACE: $stackTrace',
//       );
//     }
//   }
// }