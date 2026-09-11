import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/prayer_scheduler_config.dart';

void prayerSchedulerLog(String message) {
  debugPrint('🔔 [PrayerNotification] $message');
}

class CountdownNotificationService {
  const CountdownNotificationService._();

  static Future<void> showNextPrayerCountdown() async {
    prayerSchedulerLog('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    prayerSchedulerLog('🚀 START showNextPrayerCountdown()');

    try {
      WidgetsFlutterBinding.ensureInitialized();

      final prefs = await SharedPreferences.getInstance();

      final jsonString =
          prefs.getString(prayerNotificationWindowPrefsKey);

      if (jsonString == null || jsonString.isEmpty) {
        prayerSchedulerLog('❌ ERROR: No saved prayer window found');
        return;
      }

      late final List<dynamic> entries;

      try {
        entries = jsonDecode(jsonString) as List<dynamic>;
      } catch (e, stackTrace) {
        prayerSchedulerLog('❌ JSON DECODE FAILED: $e');
        prayerSchedulerLog('STACKTRACE: $stackTrace');
        return;
      }

      if (entries.isEmpty) {
        prayerSchedulerLog('❌ ERROR: Prayer entries are EMPTY');
        return;
      }

      final now = DateTime.now();
      final sortedEntries = List<Map<String, dynamic>>.from(
        entries.map((e) => Map<String, dynamic>.from(e as Map)),
      )..sort((a, b) {
        final timeA = DateTime.tryParse(a['time'] as String) ?? DateTime(0);
        final timeB = DateTime.tryParse(b['time'] as String) ?? DateTime(0);
        return timeA.compareTo(timeB);
      });
      Map<String, dynamic>? next;

      for (var i = 0; i < entries.length; i++) {
        try {
          final entry = Map<String, dynamic>.from(entries[i] as Map);
          final time = DateTime.parse(entry['time'] as String);

          if (time.isAfter(now)) {
            next = entry;
            break;
          }
        } catch (e) {
          prayerSchedulerLog('⚠️ Invalid entry at index=$i: $e');
        }
      }

      if (next == null) {
        prayerSchedulerLog('❌ NO UPCOMING PRAYER FOUND');
        return;
      }

      final nextPrayerName = next['name'] as String;
      final nextPrayerTime = DateTime.parse(next['time'] as String);

      final notifications = FlutterLocalNotificationsPlugin();

      const androidSettings =
          AndroidInitializationSettings(notificationIcon);

      const initializationSettings =
          InitializationSettings(android: androidSettings);

      try {
        await notifications.initialize(
          settings: initializationSettings,
        );
      } catch (e, stackTrace) {
        prayerSchedulerLog(
          '❌ FlutterLocalNotifications INITIALIZE FAILED: $e',
        );
        prayerSchedulerLog('STACKTRACE: $stackTrace');
        return;
      }

      final androidPlugin = notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

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
      } catch (e, stackTrace) {
        prayerSchedulerLog('❌ CHANNEL CREATION FAILED: $e');
        prayerSchedulerLog('STACKTRACE: $stackTrace');
      }

      final remaining = nextPrayerTime.difference(now);
      final countdownEnd = DateTime.now().add(remaining);

      final androidDetails = AndroidNotificationDetails(
        countdownChannelId,
        countdownChannelName,
        channelDescription: countdownChannelDescription,
        icon: notificationIcon,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        silent: true,
        playSound: false,
        showWhen: true,
        usesChronometer: true,
        chronometerCountDown: true,
        when: countdownEnd.millisecondsSinceEpoch,
        category: AndroidNotificationCategory.status,
        visibility: NotificationVisibility.public,
        channelShowBadge: false,
      );

      await notifications.show(
        id: countdownNotificationId,
        title: '🕌 الصلاة القادمة',
        body: 'صلاة $nextPrayerName',
        notificationDetails: NotificationDetails(
          android: androidDetails,
        ),
        payload: 'next_prayer',
      );

      prayerSchedulerLog(
        '🎉 NOTIFICATION SHOW SUCCESS: $nextPrayerName',
      );
    } catch (e, stackTrace) {
      prayerSchedulerLog(
        '❌ showNextPrayerCountdown FAILED: $e',
      );
      prayerSchedulerLog('STACKTRACE: $stackTrace');
    }
  }
}
