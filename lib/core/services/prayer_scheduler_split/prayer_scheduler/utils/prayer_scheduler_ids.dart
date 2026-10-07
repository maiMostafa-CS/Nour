import '../config/prayer_scheduler_config.dart';

class PrayerSchedulerIds {
  PrayerSchedulerIds._();

  static final DateTime _epoch = DateTime.utc(2020, 1, 1);

  /// Day number since a fixed date calculated in UTC to prevent DST drift
  static int _dayNumber(DateTime date) {
    final local = date.toLocal();
    final normalizedDate = DateTime.utc(
      local.year,
      local.month,
      local.day,
    );

    return normalizedDate.difference(_epoch).inDays;
  }

  /// Create a unique ID for each prayer
  static int _prayerId(
      DateTime date,
      int prayerIndex,
      int base,
      ) {
    final day = _dayNumber(date);

    return base + (day * 10) + prayerIndex;
  }

  static int adhan(
      DateTime date,
      int prayerIndex,
      ) {
    return _prayerId(
      date,
      prayerIndex,
      adhanIdBase,
    );
  }

  static int reminder(
      DateTime date,
      int prayerIndex,
      ) {
    return _prayerId(
      date,
      prayerIndex,
      reminderIdBase,
    );
  }

  static int iqama(
      DateTime date,
      int prayerIndex,
      ) {
    return _prayerId(
      date,
      prayerIndex,
      iqamaIdBase,
    );
  }

  static int countdownUpdate(
      DateTime date,
      int prayerIndex,
      ) {
    return _prayerId(
      date,
      prayerIndex,
      countdownUpdateIdBase,
    );
  }
}