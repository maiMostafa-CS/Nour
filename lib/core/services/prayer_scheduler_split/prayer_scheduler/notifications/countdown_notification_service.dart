import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../features/prayer_times/data/datasources/prayer_local_data_source.dart';
import '../config/prayer_scheduler_config.dart';

void prayerSchedulerLog(String message) {
  debugPrint('🔔 [PrayerNotification] $message');
}

class CountdownNotificationService {
  const CountdownNotificationService._();

  static Future<void> showNextPrayerCountdown() async {
    debugPrint('🚀🚀🚀 showNextPrayerCountdown CALLED');

    prayerSchedulerLog(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
    );
    prayerSchedulerLog(
      '🚀 START showNextPrayerCountdown()',
    );

    try {
      WidgetsFlutterBinding.ensureInitialized();

      final prefs = await SharedPreferences.getInstance();

      final jsonString = prefs.getString(
        prayerNotificationWindowPrefsKey,
      );

      if (jsonString == null || jsonString.isEmpty) {
        prayerSchedulerLog(
          '❌ ERROR: No saved prayer window found',
        );
        return;
      }

      late final List<dynamic> entries;

      try {
        entries = jsonDecode(jsonString) as List<dynamic>;
      } catch (e, stackTrace) {
        prayerSchedulerLog(
          '❌ JSON DECODE FAILED: $e',
        );
        prayerSchedulerLog(
          'STACKTRACE: $stackTrace',
        );
        return;
      }

      if (entries.isEmpty) {
        prayerSchedulerLog(
          '❌ ERROR: Prayer entries are EMPTY',
        );
        return;
      }

      // ==========================================================
      // Current time in UTC
      // ==========================================================

      final nowUtc = DateTime.now().toUtc();

      prayerSchedulerLog(
        '🕐 NOW DEVICE LOCAL: ${DateTime.now()}',
      );

      prayerSchedulerLog(
        '🌐 NOW UTC: $nowUtc',
      );

      // ==========================================================
      // Convert entries to Map
      // ==========================================================

      final sortedEntries =
      List<Map<String, dynamic>>.from(
        entries.map(
              (e) => Map<String, dynamic>.from(
            e as Map,
          ),
        ),
      );

      // ==========================================================
      // Sort prayers by time
      // ==========================================================

      sortedEntries.sort(
            (a, b) {
          final timeA =
              DateTime.tryParse(
                a['time'] as String,
              )?.toUtc() ??
                  DateTime.fromMillisecondsSinceEpoch(
                    0,
                    isUtc: true,
                  );

          final timeB =
              DateTime.tryParse(
                b['time'] as String,
              )?.toUtc() ??
                  DateTime.fromMillisecondsSinceEpoch(
                    0,
                    isUtc: true,
                  );

          return timeA.compareTo(timeB);
        },
      );

      // ==========================================================
      // Find the next prayer
      // ==========================================================

      Map<String, dynamic>? next;

      for (var i = 0; i < sortedEntries.length; i++) {
        try {
          final entry = sortedEntries[i];

          final time = DateTime.parse(
            entry['time'] as String,
          ).toUtc();

          prayerSchedulerLog(
            '🔎 CHECK: ${entry['name']} | $time',
          );

          if (time.isAfter(nowUtc)) {
            next = entry;

            prayerSchedulerLog(
              '✅ UPCOMING FOUND: ${entry['name']}',
            );

            break;
          }
        } catch (e) {
          prayerSchedulerLog(
            '⚠️ Invalid entry at index=$i: $e',
          );
        }
      }

      // ==========================================================
      // No upcoming prayer in current entries -> calculate tomorrow
      // ==========================================================

      if (next == null) {
        prayerSchedulerLog(
          '⚠️ No upcoming prayer in window. Calculating next day...',
        );
        final lat = prefs.getDouble(prayerLastLatitudePrefsKey);
        final lng = prefs.getDouble(prayerLastLongitudePrefsKey);
        if (lat != null && lng != null) {
          final now = DateTime.now();
          final tomorrow = now.add(const Duration(days: 1));
          final calc = PrayerLocalDataSourceImpl();
          final tomorrowSchedule = calc.calculate(
            latitude: lat,
            longitude: lng,
            date: tomorrow,
          );
          final tomorrowEntries = <Map<String, String>>[
            {'name': 'الفجر', 'time': tomorrowSchedule.fajr.toIso8601String()},
            {'name': 'الشروق', 'time': tomorrowSchedule.sunrise.toIso8601String()},
            {'name': 'الظهر', 'time': tomorrowSchedule.dhuhr.toIso8601String()},
            {'name': 'العصر', 'time': tomorrowSchedule.asr.toIso8601String()},
            {'name': 'المغرب', 'time': tomorrowSchedule.maghrib.toIso8601String()},
            {'name': 'العشاء', 'time': tomorrowSchedule.isha.toIso8601String()},
          ];
          for (final entry in tomorrowEntries) {
            final t = DateTime.parse(entry['time']!).toUtc();
            if (t.isAfter(nowUtc)) {
              next = entry;
              break;
            }
          }
        }
      }

      if (next == null) {
        prayerSchedulerLog(
          '❌ NO UPCOMING PRAYER FOUND',
        );
        return;
      }

      // ==========================================================
      // Next prayer data
      // ==========================================================

      final nextPrayerName = next['name'] as String;

      final nextPrayerTime = DateTime.parse(
        next['time'] as String,
      ).toUtc();

      final localTime = nextPrayerTime.toLocal();
      final hour = localTime.hour == 0
          ? 12
          : localTime.hour > 12
              ? localTime.hour - 12
              : localTime.hour;
      final minute = localTime.minute.toString().padLeft(2, '0');
      final period = localTime.hour >= 12 ? 'م' : 'ص';
      final formattedTime = '$hour:$minute $period';

      // ==========================================================
      // Calculate the difference
      // ==========================================================

      final remaining = nextPrayerTime.difference(nowUtc);

      prayerSchedulerLog(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );
      prayerSchedulerLog(
        '🕌 NEXT PRAYER: $nextPrayerName',
      );
      prayerSchedulerLog(
        '🕐 NOW DEVICE LOCAL: ${DateTime.now()}',
      );
      prayerSchedulerLog(
        '🌐 NOW UTC: $nowUtc',
      );
      prayerSchedulerLog(
        '⏰ PRAYER UTC: $nextPrayerTime',
      );
      prayerSchedulerLog(
        '⏳ REMAINING: $remaining',
      );
      prayerSchedulerLog(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );

      // ==========================================================
      // Flutter Local Notifications
      // ==========================================================

      final notifications = FlutterLocalNotificationsPlugin();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const initializationSettings = InitializationSettings(
        android: androidSettings,
      );

      try {
        await notifications.initialize(
          settings: initializationSettings,
        );
      } catch (e, stackTrace) {
        prayerSchedulerLog(
          '❌ FlutterLocalNotifications INITIALIZE FAILED: $e',
        );
        prayerSchedulerLog(
          'STACKTRACE: $stackTrace',
        );
        return;
      }

      // ==========================================================
      // Android Plugin
      // ==========================================================

      final androidPlugin = notifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      // ==========================================================
      // Notification Channel (Low importance & silent for persistent countdown)
      // ==========================================================

      const countdownChannel = AndroidNotificationChannel(
        countdownChannelId,
        countdownChannelName,
        description: countdownChannelDescription,
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      );

      try {
        await androidPlugin?.createNotificationChannel(
          countdownChannel,
        );
      } catch (e, stackTrace) {
        prayerSchedulerLog(
          '❌ CHANNEL CREATION FAILED: $e',
        );
        prayerSchedulerLog(
          'STACKTRACE: $stackTrace',
        );
      }

      // ==========================================================
      // Notification Details (Persistent, non-dismissible, real-time countdown)
      // ==========================================================

      final androidDetails = AndroidNotificationDetails(
        countdownChannelId,
        countdownChannelName,
        channelDescription: countdownChannelDescription,
        icon: '@mipmap/ic_launcher',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        silent: true,
        playSound: false,
        enableVibration: false,
        onlyAlertOnce: true,
        showWhen: true,
        usesChronometer: true,
        chronometerCountDown: true,
        when: nextPrayerTime.millisecondsSinceEpoch,
        visibility: NotificationVisibility.public,
        channelShowBadge: false,
      );

      // ==========================================================
      // Show / Update Notification
      // ==========================================================

      await notifications.show(
        id: countdownNotificationId,
        title: '🕌 الصلاة القادمة: $nextPrayerName',
        body: 'موعد الأذان: $formattedTime',
        notificationDetails: NotificationDetails(
          android: androidDetails,
        ),
        payload: 'next_prayer',
      );
      debugPrint('🎯 SHOW CALLED WITH PRAYER: $nextPrayerName');
      debugPrint('✅✅✅ NOTIFICATION SHOWED: $nextPrayerName');

      // ==========================================================
      // Success Logs
      // ==========================================================

      prayerSchedulerLog(
        '🎉 NOTIFICATION SHOW SUCCESS: '
            '$nextPrayerName',
      );

      prayerSchedulerLog(
        '⏳ REMAINING (UTC): $remaining',
      );

      prayerSchedulerLog(
        '⏱️ COUNTDOWN TARGET: '
            '$nextPrayerTime',
      );

      prayerSchedulerLog(
        '➕ CHRONOMETER MODE: '
            'ELAPSED / NEGATIVE TARGET',
      );

      prayerSchedulerLog(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );
    } catch (e, stackTrace) {
      debugPrint('❌❌❌ showNextPrayerCountdown FAILED: $e');
      prayerSchedulerLog('❌ showNextPrayerCountdown FAILED: $e');
      prayerSchedulerLog('STACKTRACE: $stackTrace');
    }
  }
}