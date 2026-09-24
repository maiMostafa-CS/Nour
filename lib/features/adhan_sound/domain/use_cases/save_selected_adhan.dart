import '../repositories/adhan_repository.dart';

class SaveSelectedAdhan {
  final AdhanRepository repository;

  const SaveSelectedAdhan(this.repository);

  Future<void> call(
      String prayerName,
      String reciterId,
      ) {
    return repository.saveSelectedReciter(
      prayerName,
      reciterId,
    );
  }
}