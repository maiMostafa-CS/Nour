import '../../domain/entities/khatma_progress.dart';
import '../../domain/entities/khatma_weekly_report.dart';
import '../../domain/repositories/khatma_repository.dart';
import '../datasources/khatma_local_data_source.dart';

class KhatmaRepositoryImpl implements KhatmaRepository {
  final KhatmaLocalDataSource localDataSource;

  KhatmaRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<KhatmaProgress> getProgress() {
    return localDataSource.getProgress();
  }

  @override
  Future<KhatmaProgress> markCurrentAyahAsRead() {
    return localDataSource.markCurrentAyahAsRead();
  }

  @override
  Future<KhatmaWeeklyReport> getWeeklyReport() {
    return localDataSource.getWeeklyReport();
  }

  @override
  Future<void> reset() {
    return localDataSource.reset();
  }
}