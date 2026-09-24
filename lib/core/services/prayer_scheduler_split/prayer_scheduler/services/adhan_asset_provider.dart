

import '../../../../../features/adhan_sound/data/datasources/adhan_local_data_source.dart';
import '../../../../../features/adhan_sound/domain/entities/adhan_reciter_entity.dart';

class AdhanAssetProvider {
  final AdhanLocalDataSource localDataSource;

  const AdhanAssetProvider({
    required this.localDataSource,
  });

  Future<AdhanReciterEntity> getSelectedReciter(
      String prayerName,
      ) async {
    final reciters =
    await localDataSource.getRecitersForPrayer(prayerName);

    if (reciters.isEmpty) {
      throw Exception(
        'No adhan reciters available for $prayerName',
      );
    }

    final selectedId =
    await localDataSource.getSelectedReciterId(prayerName);

    if (selectedId == null) {
      return reciters.first;
    }

    return reciters.firstWhere(
          (reciter) => reciter.id == selectedId,
      orElse: () => reciters.first,
    );
  }

  Future<String> getAssetForPrayer(String prayerName) async {
    final reciter = await getSelectedReciter(prayerName);
    return reciter.normalAdhanAssetPath;
  }
}