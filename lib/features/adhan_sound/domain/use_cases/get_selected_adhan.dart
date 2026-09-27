import '../entities/adhan_reciter_entity.dart';
import '../repositories/adhan_repository.dart';

class GetSelectedAdhan {
  final AdhanRepository repository;

  const GetSelectedAdhan(this.repository);

  /// Returns the selected reciter ID for a specific prayer
  Future<String?> call(String prayerName) {
    return repository.getSelectedReciterId(prayerName);
  }

  /// Returns the selected reciter as a complete entity
  Future<AdhanReciterEntity?> callEntity(String prayerName) {
    return repository.getSelectedReciter(prayerName);
  }
}