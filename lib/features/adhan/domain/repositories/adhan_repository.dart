import '../entities/adhan_reciter_entity.dart';

abstract class AdhanRepository {
  Future<List<AdhanReciterEntity>> getReciters();

  Future<String?> getSelectedReciterId();

  Future<void> saveSelectedReciter(String reciterId);
}