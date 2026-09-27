abstract class PrayerNotificationRepository {
  /// Schedules the first window (first launch, or after opening the app if there is a gap).
  Future<void> scheduleNotifications({
    required double latitude,
    required double longitude,
    int days,
  });

  Future<void> cancelNotifications();


  Future<void> rescheduleNotifications({
    required double latitude,
    required double longitude,
    int days,
  });
  Future<void> onAlarmFired({
    required double latitude,
    required double longitude,
    int days,
  });
}