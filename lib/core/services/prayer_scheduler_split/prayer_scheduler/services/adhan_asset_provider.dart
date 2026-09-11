import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../features/adhan/data/datasources/adhan_local_data_source.dart';
import '../../../../../features/adhan/domain/entities/adhan_reciter_entity.dart';


class AdhanAssetProvider {
  final AdhanLocalDataSource localDataSource;

  const AdhanAssetProvider({
    required this.localDataSource,
  });

  Future<AdhanReciterEntity> getSelectedReciter() async {
    final reciters = await localDataSource.getReciters();

    final selectedId =
    await localDataSource.getSelectedReciterId();

    if (reciters.isEmpty) {
      throw Exception('No adhan reciters available');
    }

    return reciters.firstWhere(
          (reciter) => reciter.id == selectedId,
      orElse: () => reciters.first,
    );
  }

  Future<String> getAssetForPrayer(String prayerName) async {
    final reciter = await getSelectedReciter();

    if (prayerName == 'fajr') {
      return reciter.fajrAdhanAssetPath;
    }

    return reciter.normalAdhanAssetPath;
  }
}