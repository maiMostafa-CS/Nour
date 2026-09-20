import '../entities/khatma_progress.dart';

abstract class KhatmaRepository {
  Future<KhatmaProgress> getProgress();

  Future<KhatmaProgress> markCurrentAyahAsRead();

  Future<void> reset();
}