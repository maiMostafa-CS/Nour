abstract class PrayerNotificationRepository {
  /// يجدول أول نافذة (أول مرة، أو بعد فتح التطبيق لو فيه فجوة).
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