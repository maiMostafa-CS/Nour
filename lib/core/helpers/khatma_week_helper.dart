class KhatmaWeekHelper {
  static DateTime startOfWeek(DateTime date) {
    final normalized = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final daysFromMonday = normalized.weekday - DateTime.monday;

    return normalized.subtract(
      Duration(days: daysFromMonday),
    );
  }

  static String weekKey(DateTime date) {
    final start = startOfWeek(date);

    final month = start.month.toString().padLeft(2, '0');
    final day = start.day.toString().padLeft(2, '0');

    return '${start.year}-$month-$day';
  }
}