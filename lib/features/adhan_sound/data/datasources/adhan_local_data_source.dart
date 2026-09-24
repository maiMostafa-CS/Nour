import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/adhan_reciter_entity.dart';

abstract class AdhanLocalDataSource {
  Future<List<AdhanReciterEntity>> getReciters();

  Future<List<AdhanReciterEntity>> getRecitersForPrayer(String prayerName);

  Future<List<AdhanReciterEntity>> getFajrReciters();
  Future<List<AdhanReciterEntity>> getDhuhrReciters();
  Future<List<AdhanReciterEntity>> getAsrReciters();
  Future<List<AdhanReciterEntity>> getMaghribReciters();
  Future<List<AdhanReciterEntity>> getIshaReciters();

  Future<String?> getSelectedReciterId(String prayerName);

  /// يرجّع المؤذن المختار كـ entity كاملة (أو null لو مفيش اختيار)
  Future<AdhanReciterEntity?> getSelectedReciter(String prayerName);

  Future<void> saveSelectedReciter(
      String prayerName,
      String reciterId,
      );
}

class AdhanLocalDataSourceImpl implements AdhanLocalDataSource {
  final SharedPreferences prefs;

  const AdhanLocalDataSourceImpl({required this.prefs});

  // =========================
  // Reciters per prayer
  // =========================

  static const Map<String, List<AdhanReciterEntity>> _recitersByPrayer = {
    'fajr': [
      AdhanReciterEntity(
        id: 'fajr_yasser',
        name: 'ياسر الدوسري',
        normalAdhanAssetPath: 'assets/adhan-mp3/yaserAldosery.mp3',
      ),
      AdhanReciterEntity(
        id: 'fajr_abdulbasit',
        name: 'عبد الباسط',
        normalAdhanAssetPath:
        'assets/adhan-mp3/Abdulbasit_Abdusamad_5.mp3',
      ),
      AdhanReciterEntity(
        id: 'dhuhr_yassin',
        name: 'ياسين عساف',
        normalAdhanAssetPath:
        'assets/adhan-mp3/abdul_majid_al_surehi_1.mp3',
      ),
    ],
    'dhuhr': [
      AdhanReciterEntity(
        id: 'dhuhr_yasser',
        name: 'ياسر الدوسري',
        normalAdhanAssetPath: 'assets/adhan-mp3/yaserAldosery.mp3',
      ),
      AdhanReciterEntity(
        id: 'dhuhr_yassin',
        name: 'ياسين عساف',
        normalAdhanAssetPath:
        'assets/adhan-mp3/abdul_majid_al_surehi_1.mp3',
      ),
      AdhanReciterEntity(
        id: 'isha_abdulbasit',
        name: 'عبد الباسط',
        normalAdhanAssetPath:
        'assets/adhan-mp3/Abdulbasit_Abdusamad_5.mp3',
      ),
    ],
    'asr': [
      AdhanReciterEntity(
        id: 'asr_yasser',
        name: 'ياسر الدوسري',
        normalAdhanAssetPath: 'assets/adhan-mp3/yaserAldosery.mp3',
      ),
      AdhanReciterEntity(
        id: 'dhuhr_yassin',
        name: 'ياسين عساف',
        normalAdhanAssetPath:
        'assets/adhan-mp3/abdul_majid_al_surehi_1.mp3',
      ),
      AdhanReciterEntity(
        id: 'isha_abdulbasit',
        name: 'عبد الباسط',
        normalAdhanAssetPath:
        'assets/adhan-mp3/Abdulbasit_Abdusamad_5.mp3',
      ),
    ],
    'maghrib': [
      AdhanReciterEntity(
        id: 'maghrib_yassin',
        name: 'ياسين عساف',
        normalAdhanAssetPath:
        'assets/adhan-mp3/abdul_majid_al_surehi_1.mp3',
      ),
      AdhanReciterEntity(
        id: 'isha_abdulbasit',
        name: 'عبد الباسط',
        normalAdhanAssetPath:
        'assets/adhan-mp3/Abdulbasit_Abdusamad_5.mp3',
      ),
      AdhanReciterEntity(
        id: 'asr_yasser',
        name: 'ياسر الدوسري',
        normalAdhanAssetPath: 'assets/adhan-mp3/yaserAldosery.mp3',
      ),
    ],
    'isha': [
      AdhanReciterEntity(
        id: 'isha_abdulbasit',
        name: 'عبد الباسط',
        normalAdhanAssetPath:
        'assets/adhan-mp3/Abdulbasit_Abdusamad_5.mp3',
      ),
      AdhanReciterEntity(
        id: 'dhuhr_yassin',
        name: 'ياسين عساف',
        normalAdhanAssetPath:
        'assets/adhan-mp3/abdul_majid_al_surehi_1.mp3',
      ),
      AdhanReciterEntity(
        id: 'asr_yasser',
        name: 'ياسر الدوسري',
        normalAdhanAssetPath: 'assets/adhan-mp3/yaserAldosery.mp3',
      ),
    ],
  };

  // =========================
  // Helpers
  // =========================

  String _normalize(String prayerName) => prayerName.trim().toLowerCase();

  List<AdhanReciterEntity> _recitersFor(String prayerName) {
    return _recitersByPrayer[_normalize(prayerName)] ?? const [];
  }

  // =========================
  // Reciters per prayer (public)
  // =========================

  @override
  Future<List<AdhanReciterEntity>> getRecitersForPrayer(
      String prayerName,
      ) async {
    return _recitersFor(prayerName);
  }

  @override
  Future<List<AdhanReciterEntity>> getFajrReciters() async =>
      _recitersFor('fajr');

  @override
  Future<List<AdhanReciterEntity>> getDhuhrReciters() async =>
      _recitersFor('dhuhr');

  @override
  Future<List<AdhanReciterEntity>> getAsrReciters() async =>
      _recitersFor('asr');

  @override
  Future<List<AdhanReciterEntity>> getMaghribReciters() async =>
      _recitersFor('maghrib');

  @override
  Future<List<AdhanReciterEntity>> getIshaReciters() async =>
      _recitersFor('isha');

  // =========================
  // Selected Reciter
  // =========================

  String _getKey(String prayerName) =>
      'selected_${_normalize(prayerName)}_reciter';

  @override
  Future<String?> getSelectedReciterId(String prayerName) async {
    return prefs.getString(_getKey(prayerName));
  }

  @override
  Future<AdhanReciterEntity?> getSelectedReciter(String prayerName) async {
    final id = await getSelectedReciterId(prayerName);
    if (id == null) return null;

    for (final reciter in _recitersFor(prayerName)) {
      if (reciter.id == id) return reciter;
    }
    return null;
  }

  @override
  Future<void> saveSelectedReciter(
      String prayerName,
      String reciterId,
      ) async {
    await prefs.setString(_getKey(prayerName), reciterId);
  }

  // =========================
  // All Reciters (unique by id)
  // =========================

  @override
  Future<List<AdhanReciterEntity>> getReciters() async {
    final unique = <String, AdhanReciterEntity>{};
    for (final list in _recitersByPrayer.values) {
      for (final reciter in list) {
        unique[reciter.id] = reciter;
      }
    }
    return unique.values.toList(growable: false);
  }
}