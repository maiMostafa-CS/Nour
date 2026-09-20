import '../entities/khatma_progress.dart';
import '../repositories/khatma_repository.dart';

class MarkCurrentAyahAsRead {
  final KhatmaRepository repository;

  MarkCurrentAyahAsRead(this.repository);

  Future<KhatmaProgress> call() {
    return repository.markCurrentAyahAsRead();
  }
}