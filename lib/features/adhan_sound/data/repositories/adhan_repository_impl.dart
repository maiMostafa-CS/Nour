import '../../domain/entities/adhan_reciter_entity.dart';
import '../../domain/repositories/adhan_repository.dart';
import '../datasources/adhan_local_data_source.dart';

class AdhanRepositoryImpl implements AdhanRepository {
  final AdhanLocalDataSource localDataSource;

  const AdhanRepositoryImpl({
    required this.localDataSource,
  });

  // =========================
  // Reciters
  // =========================

  @override
  Future<List<AdhanReciterEntity>> getReciters() {
    return localDataSource.getReciters();
  }

  @override
  Future<List<AdhanReciterEntity>> getRecitersForPrayer(
      String prayerName,
      ) {
    return localDataSource.getRecitersForPrayer(prayerName);
  }

  @override
  Future<List<AdhanReciterEntity>> getFajrReciters() {
    return localDataSource.getFajrReciters();
  }

  @override
  Future<List<AdhanReciterEntity>> getDhuhrReciters() {
    return localDataSource.getDhuhrReciters();
  }

  @override
  Future<List<AdhanReciterEntity>> getAsrReciters() {
    return localDataSource.getAsrReciters();
  }

  @override
  Future<List<AdhanReciterEntity>> getMaghribReciters() {
    return localDataSource.getMaghribReciters();
  }

  @override
  Future<List<AdhanReciterEntity>> getIshaReciters() {
    return localDataSource.getIshaReciters();
  }

  // =========================
  // Selected Reciter
  // =========================

  @override
  Future<String?> getSelectedReciterId(String prayerName) {
    return localDataSource.getSelectedReciterId(prayerName);
  }

  @override
  Future<AdhanReciterEntity?> getSelectedReciter(String prayerName) {
    return localDataSource.getSelectedReciter(prayerName);
  }

  @override
  Future<void> saveSelectedReciter(
      String prayerName,
      String reciterId,
      ) {
    return localDataSource.saveSelectedReciter(
      prayerName,
      reciterId,
    );
  }
}