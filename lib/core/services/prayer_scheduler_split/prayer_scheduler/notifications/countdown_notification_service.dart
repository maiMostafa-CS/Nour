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
      // الوقت الحالي UTC
      // ==========================================================

      final nowUtc = DateTime.now().toUtc();

      prayerSchedulerLog(
        '🕐 NOW DEVICE LOCAL: ${DateTime.now()}',
      );

      prayerSchedulerLog(
        '🌐 NOW UTC: $nowUtc',
      );

      // ==========================================================
      // تحويل Entries إلى Map
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
      // ترتيب الصلوات حسب الوقت
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
      // البحث عن الصلاة القادمة
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
      // لا توجد صلاة قادمة
      // ==========================================================

      if (next == null) {
        prayerSchedulerLog(
          '❌ NO UPCOMING PRAYER FOUND',
        );
        return;
      }

      // ==========================================================
      // بيانات الصلاة القادمة
      // ==========================================================

      final nextPrayerName =
      next['name'] as String;

      final nextPrayerTime =
      DateTime.parse(
        next['time'] as String,
      ).toUtc();

      // ==========================================================
      // حساب الفرق
      // ==========================================================

      final remaining =
      nextPrayerTime.difference(nowUtc);

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

      final androidPlugin =
      notifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      // ==========================================================
      // Notification Channel
      // ==========================================================

      const countdownChannel =
      AndroidNotificationChannel(
        countdownChannelId,
        countdownChannelName,
        description:
        countdownChannelDescription,
        importance: Importance.low,
        playSound: false,
      );

      try {
        await androidPlugin
            ?.createNotificationChannel(
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
      // Notification Details
      // ==========================================================

      final androidDetails =
      AndroidNotificationDetails(
        countdownChannelId,
        countdownChannelName,

        channelDescription:
        countdownChannelDescription,

        icon: notificationIcon,

        importance: Importance.low,
        priority: Priority.low,

        ongoing: true,
        autoCancel: false,

        silent: true,
        playSound: false,

        showWhen: true,

        // ========================================================
        // Android Chronometer
        // ========================================================

        usesChronometer: true,

        // ========================================================
        // مهم جدًا
        //
        // false = elapsed time
        //
        // وبالتالي Android يبدأ من وقت الصلاة
        // ويعرض الزمن بالنسبة إلى الوقت الحالي.
        //
        // لو الصلاة بعد ساعتين:
        //
        // -02:00:00
        //
        // حسب طريقة عرض Android للـ Chronometer.
        // ========================================================

        chronometerCountDown: false,

        // ========================================================
        // وقت الصلاة الحقيقي كـ absolute timestamp
        // ========================================================

        when:
        nextPrayerTime
            .toUtc()
            .millisecondsSinceEpoch,

        category:
        AndroidNotificationCategory.status,

        visibility:
        NotificationVisibility.public,

        channelShowBadge: false,
      );

      // ==========================================================
      // Show Notification
      // ==========================================================

      await notifications.show(
        id: countdownNotificationId,

        title: '🕌 الصلاة القادمة',

        body: nextPrayerName,

        notificationDetails:
        NotificationDetails(
          android: androidDetails,
        ),

        payload: 'next_prayer',
      );

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
      prayerSchedulerLog(
        '❌ showNextPrayerCountdown FAILED: $e',
      );

      prayerSchedulerLog(
        'STACKTRACE: $stackTrace',
      );
    }
  }
}