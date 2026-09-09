abstract class PrayerNotificationLocalDataSource {
  /// يمسح كل حاجة قديمة ويجدول [days] يوم من النهاردة من الصفر.
  Future<void> scheduleForDays({
    required double latitude,
    required double longitude,
    required int days,
  });

  /// يتأكد إن فيه [days] يوم قدام دايماً مجدولين. لو النافذة الحالية
  /// كافية، ملهاش تأثير. لو قربت تخلص أو مفيش نافذة أصلاً، بتنادي
  /// [scheduleForDays] عشان تبنيها من جديد.
  Future<void> ensureWindowScheduled({
    required double latitude,
    required double longitude,
    int days = 2,
  });

  /// بتتنادى من Alarm.ringing listener بعد كل أذان/تنبيه/إقامة يرن،
  /// عشان تمد النافذة تلقائياً (auto-renew) من غير ما المستخدم يفتح
  /// التطبيق.
  Future<void> onAlarmFired({
    required double latitude,
    required double longitude,
    int days = 2,
  });

  Future<void> cancelAll();
}