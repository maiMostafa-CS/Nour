import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/data/datasources/prayer_notification_local_data_source.dart';
import '../../domain/repositories/PrayerTimesRepository.dart';
class PrayerNotificationRepositoryImpl
    implements PrayerNotificationRepository {
  PrayerNotificationRepositoryImpl({
    required PrayerNotificationLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final PrayerNotificationLocalDataSource _localDataSource;

  /// عدد الأيام اللي بنحافظ على جدولتها قدام دايماً (rolling window).
  /// خليها ثابتة هنا عشان كل الـ callers (init, resume, onAlarmFired)
  /// يستخدموا نفس الرقم من غير ما يكرروه.
  static const int _windowDays = 2;

  @override
  Future<void> scheduleNotifications({
    required double latitude,
    required double longitude,
    int days = _windowDays,
  }) {
    // أول مرة (أو بعد تغيير الموقع): تأكد إن النافذة مجدولة من الصفر.
    return _localDataSource.ensureWindowScheduled(
      latitude: latitude,
      longitude: longitude,
      days: days,
    );
  }

  @override
  Future<void> cancelNotifications() => _localDataSource.cancelAll();

  @override
  Future<void> rescheduleNotifications({
    required double latitude,
    required double longitude,
    int days = _windowDays,
  }) async {
    // إعادة جدولة كاملة (مثلاً بعد تغيير الموقع): امسح كل حاجة قديمة
    // الأول عشان محدش يفضل مجدول بإحداثيات غلط، وبعدين ابني النافذة
    // من جديد بالإحداثيات الجديدة.
    await _localDataSource.cancelAll();
    return _localDataSource.ensureWindowScheduled(
      latitude: latitude,
      longitude: longitude,
      days: days,
    );
  }

  @override
  Future<void> onAlarmFired({
    required double latitude,
    required double longitude,
    int days = _windowDays,
  }) {
    // بينده من الـ Alarm.ringing listener في main.dart كل ما أذان/تنبيه/
    // إقامة يرن. بيكمّل النافذة يوم زيادة تلقائياً (auto-renew) من غير
    // ما نمسح حاجة، عكس reschedule اللي بتمسح وتبني من الأول.
    return _localDataSource.onAlarmFired(
      latitude: latitude,
      longitude: longitude,
      days: days,
    );
  }
}