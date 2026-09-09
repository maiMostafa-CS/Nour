abstract class PrayerNotificationRepository {
  /// يجدول أول نافذة (أول مرة، أو بعد فتح التطبيق لو فيه فجوة).
  Future<void> scheduleNotifications({
    required double latitude,
    required double longitude,
    int days,
  });

  Future<void> cancelNotifications();

  /// إعادة جدولة كاملة — بتمسح كل حاجة قديمة وتبني من جديد.
  /// استخدمها لما يتغير الموقع (lat/lng) أو إعدادات الأذان/الإقامة.
  Future<void> rescheduleNotifications({
    required double latitude,
    required double longitude,
    int days,
  });

  /// بتتنادى من Alarm.ringing listener بعد كل أذان/تنبيه/إقامة يرن.
  /// بتكمّل النافذة يوم زيادة تلقائياً من غير ما تمسح حاجة — دي اللي
  /// بتخلي الجدولة "تجدد نفسها لوحدها" من غير ما المستخدم يفتح التطبيق.
  Future<void> onAlarmFired({
    required double latitude,
    required double longitude,
    int days,
  });
}