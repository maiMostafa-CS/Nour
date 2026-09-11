import '../repositories/adhan_repository.dart';

class SaveSelectedAdhan {
  final AdhanRepository repository;

  const SaveSelectedAdhan(this.repository);

  Future<void> call(String reciterId) {
    return repository.saveSelectedReciter(
      reciterId,
    );
  }
}