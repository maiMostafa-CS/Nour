import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class PrayerAlarmLogger {
  PrayerAlarmLogger._();

  static String _currentTimezone = 'Unknown';

  static Future<void> initTimezone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      _currentTimezone = info.identifier;
    } catch (_) {
      _currentTimezone = DateTime.now().timeZoneName;
    }
  }

  static String get currentTimezone {
    if (_currentTimezone == 'Unknown') {
      _currentTimezone = DateTime.now().timeZoneName;
    }
    return _currentTimezone;
  }

  /// Format a DateTime as "YYYY-MM-DD HH:mm:ss" in local time
  static String formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    final sec = local.second.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min:$sec';
  }

  /// Logs every stage of Adhan and Iqama:
  /// Stage examples: SCHEDULE, ALARM CREATED, ALARM CALLBACK, PLAY ADHAN, NOTIFICATION SHOWN, STOP ADHAN
  static void log({
    required String type, // 'ADHAN' or 'IQAMA'
    required String stage, // 'SCHEDULE', 'ALARM CREATED', 'ALARM CALLBACK', 'PLAY ADHAN', 'PLAY IQAMA', 'NOTIFICATION SHOWN', 'STOP ADHAN', 'STOP IQAMA'
    required String prayerName,
    required int alarmId,
    required DateTime scheduledTime,
    required String status,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final now = DateTime.now();
    final buffer = StringBuffer();
    buffer.writeln('[$type][$stage]');
    buffer.writeln('Prayer: $prayerName');
    buffer.writeln('Alarm ID: $alarmId');
    buffer.writeln('Scheduled: ${formatDateTime(scheduledTime)}');
    buffer.writeln('Current: ${formatDateTime(now)}');
    buffer.writeln('Timezone: $currentTimezone');
    buffer.writeln('Status: $status');
    if (error != null) {
      buffer.writeln('Error: $error');
      if (stackTrace != null) {
        buffer.writeln('StackTrace: $stackTrace');
      }
    }

    debugPrint(buffer.toString().trimRight());
  }
}
