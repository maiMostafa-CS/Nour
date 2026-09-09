import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../features/prayer_times/data/datasources/prayer_local_data_source.dart';
import '../../../../../../features/prayer_times/domain/entities/PrayerDayScheduleEntity.dart';
import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/config/prayer_scheduler_config.dart';
import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/data/datasources/prayer_notification_local_data_source.dart';
import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/notifications/countdown_notification_service.dart';
import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/scheduler/adhan_scheduler.dart';
import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/scheduler/countdown_scheduler.dart';
import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/scheduler/iqama_scheduler.dart';
import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/scheduler/reminder_scheduler.dart';
import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/utils/prayer_scheduler_ids.dart';


// class PrayerNotificationLocalDataSourceImpl
//     implements PrayerNotificationLocalDataSource {
//   PrayerNotificationLocalDataSourceImpl({
//     required PrayerLocalDataSource prayerCalculator,
//   }) : _prayerCalculator = prayerCalculator;
//
//   final PrayerLocalDataSource _prayerCalculator;
//  static bool _isRescheduling = false;
//   @override
//   Future<void> scheduleForDays({
//     required double latitude,
//     required double longitude,
//     required int days,
//   }) async {
//     prayerSchedulerLog('════════════════════════════════════');
//     prayerSchedulerLog('🚀 START scheduleForDays()');
//     prayerSchedulerLog('📍 latitude = $latitude');
//     prayerSchedulerLog('📍 longitude = $longitude');
//     prayerSchedulerLog('📅 days = $days');
//
//     final now = DateTime.now();
//
//     final today = DateTime(
//       now.year,
//       now.month,
//       now.day,
//     );
//
//     final schedule = <DailyPrayerTimesEntity>[];
//
//     for (var d = 0; d < days; d++) {
//       final date = DateTime(
//         today.year,
//         today.month,
//         today.day + d,
//       );
//
//       final model = _prayerCalculator.calculate(
//         latitude: latitude,
//         longitude: longitude,
//         date: date,
//       );
//
//       schedule.add(
//         DailyPrayerTimesEntity(
//           date: date,
//           fajr: model.fajr,
//           dhuhr: model.dhuhr,
//           asr: model.asr,
//           maghrib: model.maghrib,
//           isha: model.isha,
//         ),
//       );
//     }
//
//     await cancelAll();
//
//     final windowEntries = <Map<String, String>>[];
//
//     var scheduledAdhans = 0;
//     var scheduledReminders = 0;
//     var scheduledIqamas = 0;
//     var scheduledCountdowns = 0;
//
//     for (var dayIndex = 0; dayIndex < schedule.length; dayIndex++) {
//       final day = schedule[dayIndex];
//
//       for (final moment in day.toMoments()) {
//         final adhanScheduled = await AdhanScheduler.schedule(
//           dayIndex: dayIndex,
//           moment: moment,
//         );
//
//         if (adhanScheduled) {
//           scheduledAdhans++;
//         }
//
//         final reminderTime =
//         moment.time.subtract(const Duration(minutes: 5));
//
//         if (reminderTime.isAfter(now)) {
//           try {
//             await ReminderScheduler.schedule(
//               dayIndex: dayIndex,
//               moment: moment,
//             );
//             scheduledReminders++;
//           } catch (e, stackTrace) {
//             prayerSchedulerLog('❌ Reminder FAILED: $e');
//             prayerSchedulerLog('STACKTRACE: $stackTrace');
//           }
//         }
//
//         final iqamaTime =
//         moment.time.add(const Duration(minutes: 15));
//
//         if (iqamaTime.isAfter(now)) {
//           try {
//             await IqamaScheduler.schedule(
//               dayIndex: dayIndex,
//               moment: moment,
//             );
//             scheduledIqamas++;
//           } catch (e, stackTrace) {
//             prayerSchedulerLog('❌ Iqama FAILED: $e');
//             prayerSchedulerLog('STACKTRACE: $stackTrace');
//           }
//         }
//
//         if (moment.time.isAfter(now)) {
//           try {
//             await CountdownScheduler.schedule(
//               dayIndex: dayIndex,
//               moment: moment,
//             );
//             scheduledCountdowns++;
//           } catch (e, stackTrace) {
//             prayerSchedulerLog('❌ Countdown update FAILED: $e');
//             prayerSchedulerLog('STACKTRACE: $stackTrace');
//           }
//         }
//
//         windowEntries.add({
//           'name': moment.name,
//           'time': moment.time.toIso8601String(),
//         });
//       }
//     }
//
//     final prefs = await SharedPreferences.getInstance();
//
//     await prefs.setInt(
//       prayerScheduledDaysPrefsKey,
//       days,
//     );
//
//     await prefs.setString(
//       prayerScheduledFromPrefsKey,
//       today.toIso8601String(),
//     );
//
//     // بنحفظ آخر إحداثيات استخدمناها عشان الـ auto-renew listener
//     // (اللي بيتنادى من Alarm.ringing جوه Foreground Service من غير
//     // ما التطبيق يكون مفتوح) يقدر يعيد الجدولة من غير ما يكون عنده
//     // وصول مباشر لموقع المستخدم وقتها.
//     await prefs.setDouble(prayerLastLatitudePrefsKey, latitude);
//     await prefs.setDouble(prayerLastLongitudePrefsKey, longitude);
//
//     await prefs.setString(
//       prayerNotificationWindowPrefsKey,
//       jsonEncode(windowEntries),
//     );
//
//     try {
//       await CountdownNotificationService.showNextPrayerCountdown();
//     } catch (e, stackTrace) {
//       prayerSchedulerLog('❌ Initial countdown FAILED: $e');
//       prayerSchedulerLog('STACKTRACE: $stackTrace');
//     }
//
//     prayerSchedulerLog('🎉 SCHEDULING FINISHED SUCCESSFULLY');
//     prayerSchedulerLog('📅 Days = $days');
//     prayerSchedulerLog('🕌 Adhans = $scheduledAdhans');
//     prayerSchedulerLog('🔔 Reminders = $scheduledReminders');
//     prayerSchedulerLog('🕋 Iqamas = $scheduledIqamas');
//     prayerSchedulerLog('⏱️ Countdown updates = $scheduledCountdowns');
//     prayerSchedulerLog('📦 Total entries = ${windowEntries.length}');
//     prayerSchedulerLog('════════════════════════════════════');
//   }
//
//   /// يتأكد إن فيه [days] يوم قدام دايماً مجدولين (نافذة متجددة).
//   ///
//   /// بيقرأ آخر تاريخ اتجدولت منه النافذة (`prayerScheduledFromPrefsKey`)
//   /// وعدد الأيام اللي اتجدولوا (`prayerScheduledDaysPrefsKey`)، وبيحسب
//   /// كام يوم "متبقي" فعلياً من النافذة القديمة من النهاردة. لو المتبقي
//   /// أقل من [days] (يعني النافذة قربت تخلص أو فيه فجوة)، بينادي
//   /// [scheduleForDays] عشان يعيد بناء نافذة كاملة [days] يوم من النهاردة.
//   ///
//   /// لو النافذة لسه كافية، الدالة مبتعملش حاجة (تجنباً لعمل cancel +
//   /// reschedule كامل لكل الـ Alarms من غير داعي).
//   @override
//   @override
//   Future<void> ensureWindowScheduled({
//     required double latitude,
//     required double longitude,
//     int days = 2,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     final scheduledFromIso =
//     prefs.getString(prayerScheduledFromPrefsKey);
//
//     final scheduledDays =
//     prefs.getInt(prayerScheduledDaysPrefsKey);
//
//     final now = DateTime.now();
//
//     final today = DateTime(
//       now.year,
//       now.month,
//       now.day,
//     );
//
//     var needsReschedule = true;
//
//     if (scheduledFromIso != null && scheduledDays != null) {
//       final scheduledFrom = DateTime.parse(scheduledFromIso);
//
//       final lastCoveredDay = scheduledFrom.add(
//         Duration(days: scheduledDays - 1),
//       );
//
//       final daysRemaining =
//           lastCoveredDay.difference(today).inDays;
//
//       needsReschedule =
//           daysRemaining < (days - 1);
//
//       prayerSchedulerLog(
//         '🔎 Window check | '
//             'daysRemaining=$daysRemaining | '
//             'needed=${days - 1} | '
//             'needsReschedule=$needsReschedule',
//       );
//     } else {
//       prayerSchedulerLog(
//         '🔎 No schedule metadata found',
//       );
//     }
//
//     // ⭐ الأهم:
//     // حتى لو الـ SharedPreferences بتقول إن الجدولة موجودة،
//     // نتأكد إن الـ Alarm نفسه موجود.
//     if (!needsReschedule) {
//       final alarmsExist = await _areAdhansScheduled(
//         days: scheduledDays!,
//       );
//
//       if (!alarmsExist) {
//         prayerSchedulerLog(
//           '🚨 PREFS VALID BUT ADHAN ALARMS ARE MISSING',
//         );
//
//         needsReschedule = true;
//       }
//     }
//
//     if (needsReschedule) {
//       prayerSchedulerLog(
//         '🔄 Rebuilding prayer alarm window...',
//       );
//
//       await scheduleForDays(
//         latitude: latitude,
//         longitude: longitude,
//         days: days,
//       );
//
//       prayerSchedulerLog(
//         '✅ Prayer alarm window rebuilt',
//       );
//     } else {
//       prayerSchedulerLog(
//         '✅ Window + ADHAN alarms are valid',
//       );
//     }
//   }
//
//   /// بتتنادى من الـ Alarm.ringing listener بعد كل أذان/تنبيه/إقامة يرن.
//   /// دي هي نقطة الـ "auto-renew": مش بتعمل حاجة تقيلة كل مرة، بس بتتأكد
//   /// (عن طريق [ensureWindowScheduled]) إن النافذة لسه كافية، وتمدها لو لأ.
//   @override
//   Future<void> onAlarmFired({
//     required double latitude,
//     required double longitude,
//     int days = 2,
//   }) {
//     return ensureWindowScheduled(
//       latitude: latitude,
//       longitude: longitude,
//       days: days,
//     );
//   }
//
//   @override
//   Future<void> cancelAll() async {
//     prayerSchedulerLog('🛑 START cancelAll()');
//
//     final prefs = await SharedPreferences.getInstance();
//
//     final previousDays =
//         prefs.getInt(prayerScheduledDaysPrefsKey) ?? 30;
//
//     final daysToClear = previousDays < 30 ? 30 : previousDays;
//
//     var cancelled = 0;
//
//     for (var d = 0; d < daysToClear; d++) {
//       for (var p = 0; p < 5; p++) {
//         final adhanId = PrayerSchedulerIds.adhan(d, p);
//         final reminderId = PrayerSchedulerIds.reminder(d, p);
//         final iqamaId = PrayerSchedulerIds.iqama(d, p);
//         final countdownId =
//         PrayerSchedulerIds.countdownUpdate(d, p);
//
//         try {
//           await Alarm.stop(adhanId);
//           await Alarm.stop(reminderId);
//           await Alarm.stop(iqamaId);
//           await AndroidAlarmManager.cancel(countdownId);
//           cancelled++;
//         } catch (e) {
//           prayerSchedulerLog(
//             '⚠️ Cancel error | day=$d | prayer=$p | error=$e',
//           );
//         }
//       }
//     }
//
//     try {
//       final notifications = FlutterLocalNotificationsPlugin();
//
//       await notifications.cancel(
//         id: countdownNotificationId,
//       );
//     } catch (e, stackTrace) {
//       prayerSchedulerLog(
//         '⚠️ Failed to cancel countdown notification',
//       );
//       prayerSchedulerLog('ERROR = $e');
//       prayerSchedulerLog('STACKTRACE = $stackTrace');
//     }
//
//     await prefs.remove(prayerScheduledDaysPrefsKey);
//     await prefs.remove(prayerScheduledFromPrefsKey);
//     await prefs.remove(prayerNotificationWindowPrefsKey);
//
//     prayerSchedulerLog(
//       '✅ cancelAll() completed | cancelled=$cancelled',
//     );
//   }
// }
// Future<bool> _areAdhansScheduled({
//   required int days,
// }) async {
//   for (var d = 0; d < days; d++) {
//     for (var p = 0; p < 5; p++) {
//       final id = PrayerSchedulerIds.adhan(d, p);
//
//       try {
//         final alarm = await Alarm.getAlarm(id);
//
//         if (alarm == null) {
//           prayerSchedulerLog(
//             '❌ ADHAN MISSING | id=$id | day=$d | prayer=$p',
//           );
//           return false;
//         }
//
//         if (!alarm.dateTime.isAfter(DateTime.now())) {
//           prayerSchedulerLog(
//             '❌ ADHAN EXPIRED | id=$id | time=${alarm.dateTime}',
//           );
//           return false;
//         }
//
//         prayerSchedulerLog(
//           '✅ ADHAN EXISTS | id=$id | time=${alarm.dateTime}',
//         );
//       } catch (e) {
//         prayerSchedulerLog(
//           '⚠️ ADHAN CHECK ERROR | id=$id | error=$e',
//         );
//         return false;
//       }
//     }
//   }
//
//   return true;
// }
import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../features/prayer_times/data/datasources/prayer_local_data_source.dart';
import '../../../../../../features/prayer_times/domain/entities/PrayerDayScheduleEntity.dart';



class PrayerNotificationLocalDataSourceImpl
    implements PrayerNotificationLocalDataSource {
  PrayerNotificationLocalDataSourceImpl({
    required PrayerLocalDataSource prayerCalculator,
  }) : _prayerCalculator = prayerCalculator;

  final PrayerLocalDataSource _prayerCalculator;

  // ============================================================
  // BUILD DAILY SCHEDULE
  // ============================================================

  Future<List<DailyPrayerTimesEntity>> _buildSchedule({
    required double latitude,
    required double longitude,
    required int days,
  }) async {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final schedule = <DailyPrayerTimesEntity>[];

    for (var d = 0; d < days; d++) {
      final date = DateTime(
        today.year,
        today.month,
        today.day + d,
      );

      final model = _prayerCalculator.calculate(
        latitude: latitude,
        longitude: longitude,
        date: date,
      );

      schedule.add(
        DailyPrayerTimesEntity(
          date: date,
          fajr: model.fajr,
          dhuhr: model.dhuhr,
          asr: model.asr,
          maghrib: model.maghrib,
          isha: model.isha,
        ),
      );
    }

    return schedule;
  }

  // ============================================================
  // CHECK FUTURE ADHAN ALARMS
  // ============================================================

  Future<bool> _areFutureAdhansScheduled({
    required double latitude,
    required double longitude,
    required int days,
  }) async {
    final now = DateTime.now();

    final schedule = await _buildSchedule(
      latitude: latitude,
      longitude: longitude,
      days: days,
    );

    for (var dayIndex = 0;
    dayIndex < schedule.length;
    dayIndex++) {
      final day = schedule[dayIndex];

      final moments = day.toMoments();

      for (var prayerIndex = 0;
      prayerIndex < moments.length;
      prayerIndex++) {
        final moment = moments[prayerIndex];

        // الصلاة التي انتهى وقتها بالفعل
        // لا نحتاج أن يكون لها Alarm.
        if (!moment.time.isAfter(now)) {
          continue;
        }
        final id = PrayerSchedulerIds.adhan(
          day.date,
          prayerIndex,
        );

        try {
          final alarm = await Alarm.getAlarm(id);

          if (alarm == null) {
            prayerSchedulerLog(
              '❌ FUTURE ADHAN MISSING | '
                  'id=$id | '
                  'prayer=${moment.name} | '
                  'time=${moment.time}',
            );

            return false;
          }

          if (!alarm.dateTime.isAfter(now)) {
            prayerSchedulerLog(
              '❌ FUTURE ADHAN EXPIRED | '
                  'id=$id | '
                  'alarmTime=${alarm.dateTime}',
            );

            return false;
          }

          prayerSchedulerLog(
            '✅ FUTURE ADHAN EXISTS | '
                'id=$id | '
                'prayer=${moment.name} | '
                'time=${alarm.dateTime}',
          );
        } catch (e, stackTrace) {
          prayerSchedulerLog(
            '❌ ADHAN CHECK FAILED | '
                'id=$id | '
                'error=$e',
          );

          prayerSchedulerLog(
            'STACKTRACE: $stackTrace',
          );

          return false;
        }
      }
    }

    return true;
  }

  // ============================================================
  // SCHEDULE FOR DAYS
  // ============================================================

  @override
  Future<void> scheduleForDays({
    required double latitude,
    required double longitude,
    required int days,
  }) async {
    prayerSchedulerLog(
      '════════════════════════════════════',
    );

    prayerSchedulerLog(
      '🚀 START scheduleForDays()',
    );

    prayerSchedulerLog(
      '📍 latitude = $latitude',
    );

    prayerSchedulerLog(
      '📍 longitude = $longitude',
    );

    prayerSchedulerLog(
      '📅 days = $days',
    );

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final schedule = await _buildSchedule(
      latitude: latitude,
      longitude: longitude,
      days: days,
    );

    // ==========================================================
    // CLEAR OLD ALARMS
    // ==========================================================


    final windowEntries = <Map<String, String>>[];

    var scheduledAdhans = 0;
    var scheduledReminders = 0;
    var scheduledIqamas = 0;
    var scheduledCountdowns = 0;

    // ==========================================================
    // SCHEDULE
    // ==========================================================

    for (var dayIndex = 0;
    dayIndex < schedule.length;
    dayIndex++) {
      final day = schedule[dayIndex];

      final moments = day.toMoments();

      for (var prayerIndex = 0;
      prayerIndex < moments.length;
      prayerIndex++) {
        final moment = moments[prayerIndex];

        // ------------------------------------------------------
        // ADHAN
        // ------------------------------------------------------



        // ------------------------------------------------------
        // REMINDER
        // ------------------------------------------------------

        final reminderTime = moment.time.subtract(
          const Duration(minutes: 5),
        );

        // if (reminderTime.isAfter(now)) {
          // try {
          //   await ReminderScheduler.schedule(
          //     dayIndex: dayIndex,
          //     moment: moment,
          //   );
          //
          //   scheduledReminders++;
          // }
          // catch (e, stackTrace) {
          //   prayerSchedulerLog(
          //     '❌ Reminder FAILED | '
          //         'prayer=${moment.name}',
          //   );
          //
          //   prayerSchedulerLog(
          //     'ERROR = $e',
          //   );
          //
          //   prayerSchedulerLog(
          //     'STACKTRACE = $stackTrace',
          //   );
          // }
        // }
        final adhanScheduled = await AdhanScheduler.schedule(
          dayIndex: dayIndex,
          moment: moment,
        );

        if (adhanScheduled) {
          scheduledAdhans++;
        }
        // ------------------------------------------------------
        // IQAMA
        // ------------------------------------------------------

        final iqamaTime = moment.time.add(
          const Duration(minutes: 15),
        );

        if (iqamaTime.isAfter(now)) {
          try {
            await IqamaScheduler.schedule(
              dayIndex: dayIndex,
              moment: moment,
            );

            scheduledIqamas++;
          } catch (e, stackTrace) {
            prayerSchedulerLog(
              '❌ Iqama FAILED | '
                  'prayer=${moment.name}',
            );

            prayerSchedulerLog(
              'ERROR = $e',
            );

            prayerSchedulerLog(
              'STACKTRACE = $stackTrace',
            );
          }
        }

        // ------------------------------------------------------
        // COUNTDOWN
        // ------------------------------------------------------

        if (moment.time.isAfter(now)) {
          try {
            await CountdownScheduler.schedule(
              moment: moment,
            );
            scheduledCountdowns++;
          } catch (e, stackTrace) {
            prayerSchedulerLog(
              '❌ Countdown update FAILED | '
                  'prayer=${moment.name}',
            );

            prayerSchedulerLog(
              'ERROR = $e',
            );

            prayerSchedulerLog(
              'STACKTRACE = $stackTrace',
            );
          }
        }

        // ------------------------------------------------------
        // SAVE WINDOW
        // ------------------------------------------------------

        windowEntries.add({
          'dayIndex': dayIndex.toString(),
          'prayerIndex': prayerIndex.toString(),
          'name': moment.name,
          'time': moment.time.toIso8601String(),
        });
      }
    }

    // ==========================================================
    // SAVE METADATA
    // ==========================================================

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      prayerScheduledDaysPrefsKey,
      days,
    );

    await prefs.setString(
      prayerScheduledFromPrefsKey,
      today.toIso8601String(),
    );

    await prefs.setString(
      prayerNotificationWindowPrefsKey,
      jsonEncode(windowEntries),
    );

    // ==========================================================
    // INITIAL COUNTDOWN
    // ==========================================================

    try {
      await CountdownNotificationService
          .showNextPrayerCountdown();
    } catch (e, stackTrace) {
      prayerSchedulerLog(
        '❌ Initial countdown FAILED',
      );

      prayerSchedulerLog(
        'ERROR = $e',
      );

      prayerSchedulerLog(
        'STACKTRACE = $stackTrace',
      );
    }

    // ==========================================================
    // LOG
    // ==========================================================

    prayerSchedulerLog(
      '🎉 SCHEDULING FINISHED SUCCESSFULLY',
    );

    prayerSchedulerLog(
      '📅 Days = $days',
    );

    prayerSchedulerLog(
      '🕌 Adhans = $scheduledAdhans',
    );

    prayerSchedulerLog(
      '🔔 Reminders = $scheduledReminders',
    );

    prayerSchedulerLog(
      '🕋 Iqamas = $scheduledIqamas',
    );

    prayerSchedulerLog(
      '⏱️ Countdown updates = $scheduledCountdowns',
    );

    prayerSchedulerLog(
      '📦 Total entries = ${windowEntries.length}',
    );

    prayerSchedulerLog(
      '════════════════════════════════════',
    );
  }

  // ============================================================
  // ENSURE WINDOW
  // ============================================================

  @override
  Future<void> ensureWindowScheduled({
    required double latitude,
    required double longitude,
    int days = 2,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final scheduledFromIso =
    prefs.getString(prayerScheduledFromPrefsKey);

    final scheduledDays =
    prefs.getInt(prayerScheduledDaysPrefsKey);

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    var needsReschedule = true;

    // ==========================================================
    // CHECK METADATA
    // ==========================================================

    if (scheduledFromIso != null &&
        scheduledDays != null &&
        scheduledDays > 0) {
      final scheduledFrom = DateTime.parse(
        scheduledFromIso,
      );

      final lastCoveredDay = scheduledFrom.add(
        Duration(
          days: scheduledDays - 1,
        ),
      );

      final daysRemaining =
          lastCoveredDay.difference(today).inDays;

      needsReschedule =
          daysRemaining < (days - 1);

      prayerSchedulerLog(
        '🔎 Window check | '
            'from=$scheduledFrom | '
            'days=$scheduledDays | '
            'last=$lastCoveredDay | '
            'daysRemaining=$daysRemaining | '
            'needed=${days - 1} | '
            'needsReschedule=$needsReschedule',
      );
    } else {
      prayerSchedulerLog(
        '🔎 No valid schedule metadata found',
      );
    }

    // ==========================================================
    // CHECK ACTUAL FUTURE ADHAN ALARMS
    // ==========================================================

    if (!needsReschedule) {
      final alarmsExist =
      await _areFutureAdhansScheduled(
        latitude: latitude,
        longitude: longitude,
        days: scheduledDays!,
      );

      if (!alarmsExist) {
        prayerSchedulerLog(
          '🚨 PREFS VALID BUT FUTURE ADHAN ALARMS ARE MISSING',
        );

        needsReschedule = true;
      }
    }

    // ==========================================================
    // REBUILD
    // ==========================================================

    if (needsReschedule) {
      prayerSchedulerLog(
        '🔄 Rebuilding prayer alarm window...',
      );

      await scheduleForDays(
        latitude: latitude,
        longitude: longitude,
        days: days,
      );

      prayerSchedulerLog(
        '✅ Prayer alarm window rebuilt',
      );
    } else {
      prayerSchedulerLog(
        '✅ Window + FUTURE ADHAN alarms are valid',
      );
    }
  }

  // ============================================================
  // ALARM FIRED
  // ============================================================

  @override
  Future<void> onAlarmFired({
    required double latitude,
    required double longitude,
    int days = 2,
  }) {
    return ensureWindowScheduled(
      latitude: latitude,
      longitude: longitude,
      days: days,
    );
  }

  // ============================================================
  // CANCEL ALL
  // ============================================================

  @override
  Future<void> cancelAll() async {
    prayerSchedulerLog(
      '🛑 START cancelAll()',
    );

    final prefs = await SharedPreferences.getInstance();

    final previousDays =
        prefs.getInt(prayerScheduledDaysPrefsKey) ?? 30;

    final daysToClear =
    previousDays < 30 ? 30 : previousDays;

    var cancelled = 0;

    final now = DateTime.now();

    final startDate = DateTime(
      now.year,
      now.month,
      now.day,
    );

    for (var d = 0; d < daysToClear; d++) {
      final date = startDate.add(Duration(days: d));

      for (var p = 0; p < 5; p++) {
        final adhanId = PrayerSchedulerIds.adhan(date, p);
        final reminderId = PrayerSchedulerIds.reminder(date, p);
        final iqamaId = PrayerSchedulerIds.iqama(date, p);
        final countdownId =
        PrayerSchedulerIds.countdownUpdate(date, p);

        try {
          await Alarm.stop(adhanId);
          await Alarm.stop(reminderId);
          await Alarm.stop(iqamaId);

          await AndroidAlarmManager.cancel(countdownId);

          cancelled++;
        } catch (e) {
          prayerSchedulerLog(
            '⚠️ Cancel error | '
                'date=$date | '
                'prayer=$p | '
                'error=$e',
          );
        }
      }
    }
    // ==========================================================
    // CANCEL COUNTDOWN NOTIFICATION
    // ==========================================================

    try {
      final notifications =
      FlutterLocalNotificationsPlugin();

      await notifications.cancel(
        id: countdownNotificationId,
      );
    } catch (e, stackTrace) {
      prayerSchedulerLog(
        '⚠️ Failed to cancel countdown notification',
      );

      prayerSchedulerLog(
        'ERROR = $e',
      );

      prayerSchedulerLog(
        'STACKTRACE = $stackTrace',
      );
    }

    // ==========================================================
    // CLEAR METADATA
    // ==========================================================

    await prefs.remove(
      prayerScheduledDaysPrefsKey,
    );

    await prefs.remove(
      prayerScheduledFromPrefsKey,
    );

    await prefs.remove(
      prayerNotificationWindowPrefsKey,
    );

    prayerSchedulerLog(
      '✅ cancelAll() completed | '
          'cancelled=$cancelled',
    );
  }
  Future<bool> _hasLocationChanged({
    required double latitude,
    required double longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final savedLatitude =
    prefs.getDouble(prayerLastLatitudePrefsKey);

    final savedLongitude =
    prefs.getDouble(prayerLastLongitudePrefsKey);

    // أول مرة
    if (savedLatitude == null || savedLongitude == null) {
      prayerSchedulerLog(
        '📍 No saved location found → RESCHEDULE',
      );

      return true;
    }

    const tolerance = 0.0001;

    final latitudeChanged =
        (savedLatitude - latitude).abs() > tolerance;

    final longitudeChanged =
        (savedLongitude - longitude).abs() > tolerance;

    final changed =
        latitudeChanged || longitudeChanged;

    prayerSchedulerLog(
      '📍 LOCATION CHECK | '
          'saved=($savedLatitude,$savedLongitude) | '
          'new=($latitude,$longitude) | '
          'changed=$changed',
    );

    return changed;
  }
}