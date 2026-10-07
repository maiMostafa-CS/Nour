/// Orphan alarm cleanup service
///
/// Usage:
/// ```dart
/// final cleaner = getIt<OrphanAlarmCleaner>();
/// await cleaner.cleanOrphans();
/// ```
///
/// ⚠️ Call `cleanOrphans()` in `main()` immediately before `runApp`,
///    and before any `forceReschedule`.

export 'alarm_id_tracker.dart';
export 'orphan_alarm_cleaner.dart';