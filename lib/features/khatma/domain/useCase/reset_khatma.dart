import '../repositories/khatma_repository.dart';

class ResetKhatma {
  final KhatmaRepository repository;

  ResetKhatma(this.repository);

  Future<void> call() {
    return repository.reset();
  }
}