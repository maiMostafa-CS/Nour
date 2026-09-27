abstract class PrayerNotificationLocalDataSource {
  /// Clears everything old and schedules [days] days from today from scratch.
  Future<void> scheduleForDays({
    required double latitude,
    required double longitude,
    required int days,
  });

  /// Ensures [days] days ahead are always scheduled. If the current window
  /// is sufficient, it does nothing. If it is nearly finished or missing, it calls
  /// [scheduleForDays] to rebuild it.
  Future<void> ensureWindowScheduled({
    required double latitude,
    required double longitude,
    int days = 2,
  });

  /// Called by the Alarm.ringing listener after every adhan/reminder/iqama rings,
  /// to extend the window automatically (auto-renew) without the user opening
  /// the app.
  Future<void> onAlarmFired({
    required double latitude,
    required double longitude,
    int days = 2,
  });

  Future<void> cancelAll();
  Future<void> forceReschedule({
    required double latitude,
    required double longitude,
    required int days,
  });
}