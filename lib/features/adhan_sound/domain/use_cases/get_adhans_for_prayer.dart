import '../entities/adhan_reciter_entity.dart';
import '../repositories/adhan_repository.dart';

class GetAdhansForPrayer {
  final AdhanRepository repository;

  const GetAdhansForPrayer(this.repository);

  Future<List<AdhanReciterEntity>> call(String prayerName) {
    return repository.getRecitersForPrayer(prayerName);
  }
}