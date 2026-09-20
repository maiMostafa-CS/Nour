import '../entities/khatma_progress.dart';
import '../repositories/khatma_repository.dart';

class GetKhatmaProgress {
  final KhatmaRepository repository;

  GetKhatmaProgress(this.repository);

  Future<KhatmaProgress> call() {
    return repository.getProgress();
  }
}