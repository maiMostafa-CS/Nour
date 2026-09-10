// import 'dart:convert';
//
// import 'package:alarm/alarm.dart';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../../../../features/prayer_times/data/datasources/prayer_local_data_source.dart';
// import '../../../../../../features/prayer_times/domain/entities/PrayerDayScheduleEntity.dart';
// import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/config/prayer_scheduler_config.dart';
// import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/data/datasources/prayer_notification_local_data_source.dart';
// import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/notifications/countdown_notification_service.dart';
// import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/scheduler/adhan_scheduler.dart';
// import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/scheduler/countdown_scheduler.dart';
// import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/scheduler/iqama_scheduler.dart';
// import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/scheduler/reminder_scheduler.dart';
// import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/utils/prayer_scheduler_ids.dart';
//
//
// class PrayerNotificationLocalDataSourceImpl
//     implements PrayerNotificationLocalDataSource {
//   PrayerNotificationLocalDataSourceImpl({
//     required PrayerLocalDataSource prayerCalculator,
//   }) : _prayerCalculator = prayerCalculator;
//
//   final PrayerLocalDataSource _prayerCalculator;
//
//   // ============================================================
//   // BUILD DAILY SCHEDULE
//   // ============================================================
//
//   Future<List<DailyPrayerTimesEntity>> _buildSchedule({
//     required double latitude,
//     required double longitude,
//     required int days,
//   }) async {
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
//     return schedule;
//   }
//
//   // ============================================================
//   // CHECK FUTURE ADHAN ALARMS
//   // ============================================================
//
//   Future<bool> _areFutureAdhansScheduled({
//     required double latitude,
//     required double longitude,
//     required int days,
//   }) async {
//     final now = DateTime.now();
//
//     final schedule = await _buildSchedule(
//       latitude: latitude,
//       longitude: longitude,
//       days: days,
//     );
//
//     for (var dayIndex = 0;
//     dayIndex < schedule.length;
//     dayIndex++) {
//       final day = schedule[dayIndex];
//
//       final moments = day.toMoments();
//
//       for (var prayerIndex = 0;
//       prayerIndex < moments.length;
//       prayerIndex++) {
//         final moment = moments[prayerIndex];
//
//         // الصلاة التي انتهى وقتها بالفعل
//         // لا نحتاج أن يكون لها Alarm.
//         if (!moment.time.isAfter(now)) {
//           continue;
//         }
//         final id = PrayerSchedulerIds.adhan(
//           day.date,
//           prayerIndex,
//         );
//
//         try {
//           final alarm = await Alarm.getAlarm(id);
//
//           if (alarm == null) {
//             prayerSchedulerLog(
//               '❌ FUTURE ADHAN MISSING | '
//                   'id=$id | '
//                   'prayer=${moment.name} | '
//                   'time=${moment.time}',
//             );
//
//             return false;
//           }
//
//           if (!alarm.dateTime.isAfter(now)) {
//             prayerSchedulerLog(
//               '❌ FUTURE ADHAN EXPIRED | '
//                   'id=$id | '
//                   'alarmTime=${alarm.dateTime}',
//             );
//
//             return false;
//           }
//
//           prayerSchedulerLog(
//             '✅ FUTURE ADHAN EXISTS | '
//                 'id=$id | '
//                 'prayer=${moment.name} | '
//                 'time=${alarm.dateTime}',
//           );
//         } catch (e, stackTrace) {
//           prayerSchedulerLog(
//             '❌ ADHAN CHECK FAILED | '
//                 'id=$id | '
//                 'error=$e',
//           );
//
//           prayerSchedulerLog(
//             'STACKTRACE: $stackTrace',
//           );
//
//           return false;
//         }
//       }
//     }
//
//     return true;
//   }
//
//   // ============================================================
//   // SCHEDULE FOR DAYS
//   // ============================================================
//
//   @override
//   Future<void> scheduleForDays({
//     required double latitude,
//     required double longitude,
//     required int days,
//   }) async {
//     prayerSchedulerLog(
//       '════════════════════════════════════',
//     );
//
//     prayerSchedulerLog(
//       '🚀 START scheduleForDays()',
//     );
//
//     prayerSchedulerLog(
//       '📍 latitude = $latitude',
//     );
//
//     prayerSchedulerLog(
//       '📍 longitude = $longitude',
//     );
//
//     prayerSchedulerLog(
//       '📅 days = $days',
//     );
//
//     final now = DateTime.now();
//
//     final today = DateTime(
//       now.year,
//       now.month,
//       now.day,
//     );
//
//     final schedule = await _buildSchedule(
//       latitude: latitude,
//       longitude: longitude,
//       days: days,
//     );
//
//     // ==========================================================
//     // CLEAR OLD ALARMS
//     // ==========================================================
//
//
//     final windowEntries = <Map<String, String>>[];
//
//     var scheduledAdhans = 0;
//     var scheduledReminders = 0;
//     var scheduledIqamas = 0;
//     var scheduledCountdowns = 0;
//
//     // ==========================================================
//     // SCHEDULE
//     // ==========================================================
//
//     for (var dayIndex = 0;
//     dayIndex < schedule.length;
//     dayIndex++) {
//       final day = schedule[dayIndex];
//
//       final moments = day.toMoments();
//
//       for (var prayerIndex = 0;
//       prayerIndex < moments.length;
//       prayerIndex++) {
//         final moment = moments[prayerIndex];
//
//         // ------------------------------------------------------
//         // ADHAN
//         // ------------------------------------------------------
//
//
//
//         // ------------------------------------------------------
//         // REMINDER
//         // ------------------------------------------------------
//
//         final reminderTime = moment.time.subtract(
//           const Duration(minutes: 5),
//         );
//
//         // if (reminderTime.isAfter(now)) {
//           // try {
//           //   await ReminderScheduler.schedule(
//           //     dayIndex: dayIndex,
//           //     moment: moment,
//           //   );
//           //
//           //   scheduledReminders++;
//           // }
//           // catch (e, stackTrace) {
//           //   prayerSchedulerLog(
//           //     '❌ Reminder FAILED | '
//           //         'prayer=${moment.name}',
//           //   );
//           //
//           //   prayerSchedulerLog(
//           //     'ERROR = $e',
//           //   );
//           //
//           //   prayerSchedulerLog(
//           //     'STACKTRACE = $stackTrace',
//           //   );
//           // }
//         // }
//         final adhanScheduled = await AdhanScheduler.schedule(
//           dayIndex: dayIndex,
//           moment: moment,
//         );
//
//         if (adhanScheduled) {
//           scheduledAdhans++;
//         }
//         // ------------------------------------------------------
//         // IQAMA
//         // ------------------------------------------------------
//
//         final iqamaTime = moment.time.add(
//           const Duration(minutes: 15),
//         );
//
//         if (iqamaTime.isAfter(now)) {
//           try {
//             await IqamaScheduler.schedule(
//               dayIndex: dayIndex,
//               moment: moment,
//             );
//
//             scheduledIqamas++;
//           } catch (e, stackTrace) {
//             prayerSchedulerLog(
//               '❌ Iqama FAILED | '
//                   'prayer=${moment.name}',
//             );
//
//             prayerSchedulerLog(
//               'ERROR = $e',
//             );
//
//             prayerSchedulerLog(
//               'STACKTRACE = $stackTrace',
//             );
//           }
//         }
//
//         // ------------------------------------------------------
//         // COUNTDOWN
//         // ------------------------------------------------------
//
//         if (moment.time.isAfter(now)) {
//           try {
//             await CountdownScheduler.schedule(
//               moment: moment,
//             );
//             scheduledCountdowns++;
//           } catch (e, stackTrace) {
//             prayerSchedulerLog(
//               '❌ Countdown update FAILED | '
//                   'prayer=${moment.name}',
//             );
//
//             prayerSchedulerLog(
//               'ERROR = $e',
//             );
//
//             prayerSchedulerLog(
//               'STACKTRACE = $stackTrace',
//             );
//           }
//         }
//
//         // ------------------------------------------------------
//         // SAVE WINDOW
//         // ------------------------------------------------------
//
//         windowEntries.add({
//           'dayIndex': dayIndex.toString(),
//           'prayerIndex': prayerIndex.toString(),
//           'name': moment.name,
//           'time': moment.time.toIso8601String(),
//         });
//       }
//     }
//
//     // ==========================================================
//     // SAVE METADATA
//     // ==========================================================
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
//     await prefs.setString(
//       prayerNotificationWindowPrefsKey,
//       jsonEncode(windowEntries),
//     );
//
//     // ==========================================================
//     // INITIAL COUNTDOWN
//     // ==========================================================
//
//     try {
//       await CountdownNotificationService
//           .showNextPrayerCountdown();
//     } catch (e, stackTrace) {
//       prayerSchedulerLog(
//         '❌ Initial countdown FAILED',
//       );
//
//       prayerSchedulerLog(
//         'ERROR = $e',
//       );
//
//       prayerSchedulerLog(
//         'STACKTRACE = $stackTrace',
//       );
//     }
//
//     // ==========================================================
//     // LOG
//     // ==========================================================
//
//     prayerSchedulerLog(
//       '🎉 SCHEDULING FINISHED SUCCESSFULLY',
//     );
//
//     prayerSchedulerLog(
//       '📅 Days = $days',
//     );
//
//     prayerSchedulerLog(
//       '🕌 Adhans = $scheduledAdhans',
//     );
//
//     prayerSchedulerLog(
//       '🔔 Reminders = $scheduledReminders',
//     );
//
//     prayerSchedulerLog(
//       '🕋 Iqamas = $scheduledIqamas',
//     );
//
//     prayerSchedulerLog(
//       '⏱️ Countdown updates = $scheduledCountdowns',
//     );
//
//     prayerSchedulerLog(
//       '📦 Total entries = ${windowEntries.length}',
//     );
//
//     prayerSchedulerLog(
//       '════════════════════════════════════',
//     );
//   }
//
//   // ============================================================
//   // ENSURE WINDOW
//   // ============================================================
//
//   @override
//   Future<void> ensureWindowScheduled({
//     required double latitude,
//     required double longitude,
//     int days = 30,
//   }) async {
//     prayerSchedulerLog(
//       '🔍 START ensureWindowScheduled()',
//     );
//
//     prayerSchedulerLog(
//       '📍 CURRENT LOCATION = $latitude,$longitude',
//     );
//
//     final prefs = await SharedPreferences.getInstance();
//
//     final scheduledFromIso =
//     prefs.getString(
//       prayerScheduledFromPrefsKey,
//     );
//
//     final scheduledDays =
//     prefs.getInt(
//       prayerScheduledDaysPrefsKey,
//     );
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
//     // ==========================================================
//     // 1. CHECK WINDOW
//     // ==========================================================
//
//     if (scheduledFromIso != null &&
//         scheduledDays != null &&
//         scheduledDays > 0) {
//       final scheduledFrom =
//       DateTime.parse(scheduledFromIso);
//
//       final lastCoveredDay =
//       scheduledFrom.add(
//         Duration(
//           days: scheduledDays - 1,
//         ),
//       );
//
//       final daysRemaining =
//           lastCoveredDay.difference(today).inDays;
//
//       needsReschedule =
//           daysRemaining < 2;
//
//       prayerSchedulerLog(
//         '🔎 WINDOW CHECK | '
//             'from=$scheduledFrom | '
//             'days=$scheduledDays | '
//             'last=$lastCoveredDay | '
//             'remaining=$daysRemaining | '
//             'needsReschedule=$needsReschedule',
//       );
//     } else {
//       prayerSchedulerLog(
//         '🔎 NO VALID SCHEDULE METADATA',
//       );
//     }
//
//     // ==========================================================
//     // 2. CHECK LOCATION
//     // ==========================================================
//
//     if (!needsReschedule) {
//       final locationChanged =
//       await _hasScheduledLocationChanged(
//         latitude: latitude,
//         longitude: longitude,
//       );
//
//       if (locationChanged) {
//         prayerSchedulerLog(
//           '🚨 LOCATION CHANGED → FORCE RESCHEDULE',
//         );
//
//         needsReschedule = true;
//       }
//     }
//
//     // ==========================================================
//     // 3. CHECK REAL ADHAN ALARMS
//     // ==========================================================
//
//     if (!needsReschedule) {
//       final alarmsExist =
//       await _areFutureAdhansScheduled(
//         latitude: latitude,
//         longitude: longitude,
//         days: scheduledDays!,
//       );
//
//       if (!alarmsExist) {
//         prayerSchedulerLog(
//           '🚨 FUTURE ADHAN ALARMS MISSING',
//         );
//
//         needsReschedule = true;
//       }
//     }
//
//     // ==========================================================
//     // 4. FORCE REBUILD
//     // ==========================================================
//
//     if (needsReschedule) {
//       prayerSchedulerLog(
//         '🔄 REBUILDING PRAYER ALARM WINDOW...',
//       );
//
//       await forceReschedule(
//         latitude: latitude,
//         longitude: longitude,
//         days: days,
//       );
//
//       prayerSchedulerLog(
//         '✅ PRAYER ALARM WINDOW REBUILT',
//       );
//     } else {
//       prayerSchedulerLog(
//         '✅ WINDOW + LOCATION + ADHAN ALARMS ARE VALID',
//       );
//     }
//   }
//
//   // ============================================================
//   // ALARM FIRED
//   // ============================================================
//
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
//   // ============================================================
//   // CANCEL ALL
//   // ============================================================
//
//   @override
//   Future<void> cancelAll() async {
//     prayerSchedulerLog(
//       '🛑 START cancelAll()',
//     );
//
//     final prefs = await SharedPreferences.getInstance();
//
//     final previousDays =
//         prefs.getInt(prayerScheduledDaysPrefsKey) ?? 30;
//
//     final daysToClear =
//     previousDays < 30 ? 30 : previousDays;
//
//     var cancelled = 0;
//
//     final now = DateTime.now();
//
//     final startDate = DateTime(
//       now.year,
//       now.month,
//       now.day,
//     );
//
//     for (var d = 0; d < daysToClear; d++) {
//       final date = startDate.add(Duration(days: d));
//
//       for (var p = 0; p < 5; p++) {
//         final adhanId = PrayerSchedulerIds.adhan(date, p);
//         final reminderId = PrayerSchedulerIds.reminder(date, p);
//         final iqamaId = PrayerSchedulerIds.iqama(date, p);
//         final countdownId =
//         PrayerSchedulerIds.countdownUpdate(date, p);
//
//         try {
//           await Alarm.stop(adhanId);
//           await Alarm.stop(reminderId);
//           await Alarm.stop(iqamaId);
//
//           await AndroidAlarmManager.cancel(countdownId);
//
//           cancelled++;
//         } catch (e) {
//           prayerSchedulerLog(
//             '⚠️ Cancel error | '
//                 'date=$date | '
//                 'prayer=$p | '
//                 'error=$e',
//           );
//         }
//       }
//     }
//     // ==========================================================
//     // CANCEL COUNTDOWN NOTIFICATION
//     // ==========================================================
//
//     try {
//       final notifications =
//       FlutterLocalNotificationsPlugin();
//
//       await notifications.cancel(
//         id: countdownNotificationId,
//       );
//     } catch (e, stackTrace) {
//       prayerSchedulerLog(
//         '⚠️ Failed to cancel countdown notification',
//       );
//
//       prayerSchedulerLog(
//         'ERROR = $e',
//       );
//
//       prayerSchedulerLog(
//         'STACKTRACE = $stackTrace',
//       );
//     }
//
//     // ==========================================================
//     // CLEAR METADATA
//     // ==========================================================
//
//     await prefs.remove(
//       prayerScheduledDaysPrefsKey,
//     );
//
//     await prefs.remove(
//       prayerScheduledFromPrefsKey,
//     );
//
//     await prefs.remove(
//       prayerNotificationWindowPrefsKey,
//     );
//
//     prayerSchedulerLog(
//       '✅ cancelAll() completed | '
//           'cancelled=$cancelled',
//     );
//   }
//   Future<bool> _hasScheduledLocationChanged({
//     required double latitude,
//     required double longitude,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     final scheduledLatitude =
//     prefs.getDouble(
//       prayerScheduledLatitudePrefsKey,
//     );
//
//     final scheduledLongitude =
//     prefs.getDouble(
//       prayerScheduledLongitudePrefsKey,
//     );
//
//     if (scheduledLatitude == null ||
//         scheduledLongitude == null) {
//       prayerSchedulerLog(
//         '📍 No scheduled location found → RESCHEDULE',
//       );
//
//       return true;
//     }
//
//     const tolerance = 0.0001;
//
//     final latitudeChanged =
//         (scheduledLatitude - latitude).abs() > tolerance;
//
//     final longitudeChanged =
//         (scheduledLongitude - longitude).abs() > tolerance;
//
//     final changed =
//         latitudeChanged || longitudeChanged;
//
//     prayerSchedulerLog(
//       '📍 SCHEDULED LOCATION CHECK | '
//           'scheduled=($scheduledLatitude,$scheduledLongitude) | '
//           'current=($latitude,$longitude) | '
//           'changed=$changed',
//     );
//
//     return changed;
//   }
//   @override
//   Future<void> forceReschedule({
//     required double latitude,
//     required double longitude,
//     required int days,
//   }) async {
//     prayerSchedulerLog(
//       '🚨 FORCE RESCHEDULE START',
//     );
//
//     prayerSchedulerLog(
//       '📍 NEW LOCATION = $latitude,$longitude',
//     );
//
//     await cancelAll();
//
//     await scheduleForDays(
//       latitude: latitude,
//       longitude: longitude,
//       days: days,
//     );
//
//     prayerSchedulerLog(
//       '✅ FORCE RESCHEDULE COMPLETED',
//     );
//   }
// }