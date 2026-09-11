import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/adhan_reciter_entity.dart';

abstract class AdhanLocalDataSource {
  Future<List<AdhanReciterEntity>> getReciters();

  Future<String?> getSelectedReciterId();

  Future<void> saveSelectedReciter(String reciterId);
}

class AdhanLocalDataSourceImpl implements AdhanLocalDataSource {
  final SharedPreferences prefs;

  static const String selectedReciterKey =
      'selected_adhan_reciter';

  const AdhanLocalDataSourceImpl({
    required this.prefs,
  });

  @override
  Future<List<AdhanReciterEntity>> getReciters() async {
    return const [
      AdhanReciterEntity(
        id: 'abdul_majid',
        name: 'عبد المجيد السريحي',

        normalAdhanAssetPath:
        'assets/adhan-mp3/abdul_majid_al_surehi_1.mp3',

        fajrAdhanAssetPath:
        'assets/adhan-mp3/abdul_majid_al_surehi_fajr.mp3',
      ),

      AdhanReciterEntity(
        id: 'yasser_al_dosari',
        name: 'ياسر الدوسري',

        normalAdhanAssetPath:
        'assets/adhan-mp3/yasser_al_dosari.mp3',

        fajrAdhanAssetPath:
        'assets/adhan-mp3/yasser_al_dosari_fajr.mp3',
      ),

      AdhanReciterEntity(
        id: 'maher_al_muaiqly',
        name: 'ماهر المعيقلي',

        normalAdhanAssetPath:
        'assets/adhan-mp3/maher_al_muaiqly.mp3',

        fajrAdhanAssetPath:
        'assets/adhan-mp3/maher_al_muaiqly_fajr.mp3',
      ),

      AdhanReciterEntity(
        id: 'mishary_alafasy',
        name: 'مشاري العفاسي',

        normalAdhanAssetPath:
        'assets/adhan-mp3/mishary_alafasy.mp3',

        fajrAdhanAssetPath:
        'assets/adhan-mp3/mishary_alafasy_fajr.mp3',
      ),

      AdhanReciterEntity(
        id: 'nasser_al_qatami',
        name: 'ناصر القطامي',

        normalAdhanAssetPath:
        'assets/adhan-mp3/nasser_alqatami.mp3',

        fajrAdhanAssetPath:
        'assets/adhan-mp3/nasser_alqatami_fajr.mp3',
      ),
    ];
  }

  @override
  Future<String?> getSelectedReciterId() async {
    return prefs.getString(selectedReciterKey);
  }

  @override
  Future<void> saveSelectedReciter(
      String reciterId,
      ) async {
    await prefs.setString(
      selectedReciterKey,
      reciterId,
    );
  }
}