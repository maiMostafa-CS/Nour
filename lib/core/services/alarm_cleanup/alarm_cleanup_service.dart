/// خدمة تنظيف المنبهات اليتيمة
///
/// الاستخدام:
/// ```dart
/// final cleaner = getIt<OrphanAlarmCleaner>();
/// await cleaner.cleanOrphans();
/// ```
///
/// ⚠️ نادِ `cleanOrphans()` في `main()` قبل `runApp` مباشرة،
///    وقبل أي `forceReschedule`.
library alarm_cleanup_service;

export 'alarm_id_tracker.dart';
export 'orphan_alarm_cleaner.dart';