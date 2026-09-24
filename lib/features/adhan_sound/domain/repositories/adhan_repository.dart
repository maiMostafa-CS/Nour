import '../entities/adhan_reciter_entity.dart';

abstract class AdhanRepository {
  /// كل المؤذنين (بدون تكرار)
  Future<List<AdhanReciterEntity>> getReciters();

  /// مؤذني صلاة معيّنة
  Future<List<AdhanReciterEntity>> getRecitersForPrayer(String prayerName);

  Future<List<AdhanReciterEntity>> getFajrReciters();
  Future<List<AdhanReciterEntity>> getDhuhrReciters();
  Future<List<AdhanReciterEntity>> getAsrReciters();
  Future<List<AdhanReciterEntity>> getMaghribReciters();
  Future<List<AdhanReciterEntity>> getIshaReciters();

  Future<String?> getSelectedReciterId(String prayerName);

  Future<AdhanReciterEntity?> getSelectedReciter(String prayerName);

  Future<void> saveSelectedReciter(
      String prayerName,
      String reciterId,
      );
}