import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';
import 'package:islamic_app/core/services/prayer_scheduler_split/prayer_scheduler/config/prayer_scheduler_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoRenewTest {
  const AutoRenewTest._();

  // ============================================================
  // TEST CONFIG
  // ============================================================

  static const int testWindowDays = 2;

  // Reminder
  static const int testReminderAlarmId = 99997;

  // Adhan
  static const int testAdhanAlarmId = 99999;

  // Iqama
  static const int testIqamaAlarmId = 99998;

  // ============================================================
  // RUN TEST
  // ============================================================

  static Future<void> run() async {
    debugPrint('');
    debugPrint('🧪 ========================================');
    debugPrint('🧪 REMINDER + ADHAN + IQAMA REAL TEST');
    debugPrint('🧪 ========================================');

    try {
      final prefs = await SharedPreferences.getInstance();

      // ============================================================
      // 1️⃣ GET SAVED LOCATION
      // ============================================================

      final lat = prefs.getDouble(
        prayerLastLatitudePrefsKey,
      );

      final lng = prefs.getDouble(
        prayerLastLongitudePrefsKey,
      );

      debugPrint('📍 Saved latitude  = $lat');
      debugPrint('📍 Saved longitude = $lng');

      if (lat == null || lng == null) {
        debugPrint(
          '❌ TEST FAILED: coordinates are not saved',
        );
        return;
      }

      // ============================================================
      // 2️⃣ CLEAN OLD TEST ALARMS
      // ============================================================

      await _stopTestAlarm(
        testReminderAlarmId,
        'REMINDER',
      );

      await _stopTestAlarm(
        testAdhanAlarmId,
        'ADHAN',
      );

      await _stopTestAlarm(
        testIqamaAlarmId,
        'IQAMA',
      );

      debugPrint('🧹 Old test alarms cleared');

      // ============================================================
      // 3️⃣ CREATE FAKE AUTO RENEW WINDOW
      // ============================================================

      final now = DateTime.now();

      final today = DateTime(
        now.year,
        now.month,
        now.day,
      );

      // حتى نقدر نختبر حالة أن الـ window قريبة من الانتهاء
      final fakeScheduledFrom = today.subtract(
        const Duration(days: 1),
      );

      await prefs.setInt(
        prayerScheduledDaysPrefsKey,
        testWindowDays,
      );

      await prefs.setString(
        prayerScheduledFromPrefsKey,
        fakeScheduledFrom.toIso8601String(),
      );

      debugPrint('');
      debugPrint('🧪 ========================================');
      debugPrint('🧪 FAKE AUTO RENEW WINDOW');
      debugPrint('🧪 ========================================');
      debugPrint(
        '🧪 scheduledFrom = $fakeScheduledFrom',
      );
      debugPrint(
        '🧪 scheduledDays = $testWindowDays',
      );

      // ============================================================
      // 4️⃣ TEST TIMES
      // ============================================================

      // // Reminder بعد 20 ثانية
      // final reminderTime = now.add(
      //   const Duration(seconds: 10),
      // );

      // Adhan بعد 50 ثانية
      final adhanTime = now.add(
        const Duration(seconds: 20),
      );

      // Iqama بعد الأذان بـ 30 ثانية
      final iqamaTime = adhanTime.add(
        const Duration(minutes: 40),
      );

      debugPrint('');
      debugPrint('🧪 ========================================');
      debugPrint('🧪 TEST TIMES');
      debugPrint('🧪 ========================================');

      // debugPrint(
      //   '🔔 Reminder time = $reminderTime',
      // );

      debugPrint(
        '🔊 Adhan time    = $adhanTime',
      );

      debugPrint(
        '🕌 Iqama time    = $iqamaTime',
      );
      // ============================================================
      // 6️⃣ SCHEDULE ADHAN
      // ============================================================

      await Alarm.set(
        alarmSettings: AlarmSettings(
          id: testAdhanAlarmId,
          dateTime: adhanTime,

          assetAudioPath:     adhanAsset,

          loopAudio: false,
          vibrate: false,

          androidFullScreenIntent: false,
          androidStopAlarmOnTermination: false,

          volumeSettings: VolumeSettings.fixed(
            volume: 1.0,
            volumeEnforced: false,
          ),

          notificationSettings: const NotificationSettings(
            title: '🕌 اختبار الأذان',
            body: 'حان الآن وقت الأذان',
            stopButton: 'إيقاف الأذان',
            icon: notificationIcon,
            androidStopAlarmOnDismiss: false,
          ),

          payload: 'auto_renew_test_adhan',
        ),
      );

      debugPrint(
        '✅ ADHAN TEST ALARM SET '
            '| id=$testAdhanAlarmId',
      );
      // ============================================================
//       // 5️⃣ SCHEDULE REMINDER
//       // ============================================================
//
//       await Alarm.set(
//         alarmSettings: AlarmSettings(
//           id: testReminderAlarmId,
//           dateTime: reminderTime,
//
//           assetAudioPath: reminderAsset,
//
//           loopAudio: false,
//           vibrate: false,
//
//           androidFullScreenIntent: false,
//           androidStopAlarmOnTermination: false,
//
//           volumeSettings: VolumeSettings.fixed(
//             volume: 1.0,
//             volumeEnforced: false,
//           ),
//
//           notificationSettings:
//           const NotificationSettings(
//             title: '🔔 تذكير بالصلاة',
//             body: 'اقترب موعد الأذان',
//             stopButton: 'إيقاف التذكير',
//             icon: notificationIcon,
//             androidStopAlarmOnDismiss: true,
//           ),
//
//           payload: 'auto_renew_test_reminder',
//         ),
//       );
//
//       debugPrint(
//         '✅ REMINDER TEST ALARM SET '
//             '| id=$testReminderAlarmId',
//       );
//
//
//
// // 🔍 VERIFY ADHAN ALARM
//       try {
//         final alarm = await Alarm.getAlarm(
//           testAdhanAlarmId,
//         );
//
//         debugPrint(
//           '🔍 ADHAN CHECK | '
//               'exists=${alarm != null} | '
//               'time=${alarm?.dateTime}',
//         );
//       } catch (e, stackTrace) {
//         debugPrint(
//           '❌ ADHAN CHECK FAILED | error=$e',
//         );
//
//         debugPrint(
//           'STACKTRACE: $stackTrace',
//         );
//       }
//       debugPrint(
//         '✅ ADHAN TEST ALARM SET '
//             '| id=$testAdhanAlarmId',
//       );

      // ============================================================
      // 7️⃣ SCHEDULE IQAMA
      // ============================================================

      await Alarm.set(
        alarmSettings: AlarmSettings(
          id: testIqamaAlarmId,
          dateTime: iqamaTime,

          assetAudioPath: iqamaAsset,

          loopAudio: false,
          vibrate: false,

          androidFullScreenIntent: false,
          androidStopAlarmOnTermination: false,

          volumeSettings: VolumeSettings.fixed(
            volume: 1.0,
            volumeEnforced: false,
          ),

          notificationSettings:
          const NotificationSettings(
            title: '🕌 اختبار الإقامة',
            body: 'حان الآن وقت الإقامة',
            stopButton: 'إيقاف الإقامة',
            icon: notificationIcon,
            androidStopAlarmOnDismiss: true,
          ),

          payload: 'auto_renew_test_iqama',
        ),
      );

      debugPrint(
        '✅ IQAMA TEST ALARM SET '
            '| id=$testIqamaAlarmId',
      );

      // ============================================================
      // 8️⃣ TEST TIMELINE
      // ============================================================

      debugPrint('');
      debugPrint('⏳ ========================================');
      debugPrint('⏳ TEST TIMELINE');
      debugPrint('⏳ ========================================');

      debugPrint(
        '⏳ بعد 20 ثانية  → 🔔 التذكير',
      );

      debugPrint(
        '⏳ بعد 50 ثانية  → 🔊 الأذان',
      );

      debugPrint(
        '⏳ بعد 80 ثانية  → 🕌 الإقامة',
      );

      debugPrint('');
      debugPrint('✅ ========================================');
      debugPrint('✅ ALL TEST ALARMS SCHEDULED');
      debugPrint('✅ ========================================');
      debugPrint('');
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('❌ ========================================');
      debugPrint('❌ TEST FAILED');
      debugPrint('❌ ========================================');
      debugPrint('❌ ERROR: $e');
      debugPrint('❌ STACKTRACE: $stackTrace');
    }
  }

  // ============================================================
  // STOP ONE TEST ALARM
  // ============================================================

  static Future<void> _stopTestAlarm(
      int id,
      String name,
      ) async {
    try {
      await Alarm.stop(id);

      debugPrint(
        '🛑 Old $name alarm stopped | id=$id',
      );
    } catch (e) {
      debugPrint(
        'ℹ️ No old $name alarm to stop | id=$id',
      );
    }
  }

  // ============================================================
  // CANCEL ALL TEST ALARMS
  // ============================================================

  static Future<void> cancel() async {
    debugPrint('');
    debugPrint('🛑 ========================================');
    debugPrint('🛑 CANCELLING TEST ALARMS');
    debugPrint('🛑 ========================================');

    await _stopTestAlarm(
      testReminderAlarmId,
      'REMINDER',
    );

    await _stopTestAlarm(
      testAdhanAlarmId,
      'ADHAN',
    );

    await _stopTestAlarm(
      testIqamaAlarmId,
      'IQAMA',
    );

    debugPrint('');
    debugPrint(
      '🛑 Reminder + Adhan + Iqama '
          'test alarms cancelled',
    );
    debugPrint('');
  }
}