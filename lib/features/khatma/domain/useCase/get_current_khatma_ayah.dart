import '../../services/khatma_ayah_resolver.dart';
import '../entities/khatma_progress.dart';
import '../repositories/khatma_repository.dart';

class GetCurrentKhatmaAyah {
  final KhatmaRepository repository;

  GetCurrentKhatmaAyah(this.repository);

  Future<KhatmaUnlockAyah?> call() async {
    final progress = await repository.getProgress();

    if (progress.currentAyah > 6236) {
      return null;
    }

    final ayah = KhatmaAyahResolver.resolve(
      progress.currentAyah,
    );

    return KhatmaUnlockAyah(
      globalNumber: ayah.globalNumber,
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.ayahNumber,
      surahName: ayah.surahName,
      text: ayah.text,
      pageNumber: ayah.pageNumber,
    );
  }
}