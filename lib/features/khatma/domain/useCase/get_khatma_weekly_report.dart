import '../entities/khatma_weekly_report.dart';
import '../repositories/khatma_repository.dart';

class GetKhatmaWeeklyReport {
  final KhatmaRepository repository;

  GetKhatmaWeeklyReport(this.repository);

  Future<KhatmaWeeklyReport> call() {
    return repository.getWeeklyReport();
  }
}