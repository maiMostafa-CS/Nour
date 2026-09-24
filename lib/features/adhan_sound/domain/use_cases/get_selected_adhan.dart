import '../entities/adhan_reciter_entity.dart';
import '../repositories/adhan_repository.dart';

class GetSelectedAdhan {
  final AdhanRepository repository;

  const GetSelectedAdhan(this.repository);

  /// يرجّع id المؤذن المختار لصلاة معيّنة
  Future<String?> call(String prayerName) {
    return repository.getSelectedReciterId(prayerName);
  }

  /// يرجّع المؤذن المختار كـ entity كاملة
  Future<AdhanReciterEntity?> callEntity(String prayerName) {
    return repository.getSelectedReciter(prayerName);
  }
}