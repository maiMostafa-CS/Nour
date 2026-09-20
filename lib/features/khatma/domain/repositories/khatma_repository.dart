import '../entities/khatma_progress.dart';
import '../entities/khatma_weekly_report.dart';

abstract class KhatmaRepository {
  Future<KhatmaProgress> getProgress();

  Future<KhatmaProgress> markCurrentAyahAsRead();

  Future<KhatmaWeeklyReport> getWeeklyReport();

  Future<void> reset();
}