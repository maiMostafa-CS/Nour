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
        id: 'fajr_rahiq',
        name: 'ابراهيم ابو رحيق',
        normalAdhanAssetPath: 'assets/aliiqama/abo_rahiq_fajr.mp3',
      ),
      AdhanReciterEntity(
        id: 'fajr_ahmed',
        name: 'احمد الطرابلسي',
        normalAdhanAssetPath: 'assets/aliiqama/ahmed_trablsy_fajr.mp3',
      ),
      AdhanReciterEntity(
        id: 'fajr_abdulbasit',
        name: "عبد الباسط",
        normalAdhanAssetPath: 'assets/aliiqama/Abdulbasit_Abdusamad_fajr.mp3',
      ),

      AdhanReciterEntity(
        id: 'fajr_abdelmoneim',
        name: "عبد المنعم",
        normalAdhanAssetPath: 'assets/aliiqama/Abdel_Moneim_Abdel_Mobdi.mp3',
      ),
    ],
    'dhuhr': [
      AdhanReciterEntity(
        id: 'dhuhr_yasser',
        name: 'ياسر الدوسري',
        normalAdhanAssetPath: 'assets/aliiqama/Yasser_Al-Dosari_-_Saudi_Arabia.mp3',
      ),
      AdhanReciterEntity(
        id: 'dhuhr_naser',
        name: 'ناصر القطامي',
        normalAdhanAssetPath: 'assets/aliiqama/naser_alqtame.mp3',
      ),
      AdhanReciterEntity(
        id: 'dhuhr_abdulbasit',
        name: "عبد الباسط",
        normalAdhanAssetPath: 'assets/aliiqama/Abdulbasit_Abdusamad_3.mp3',
      ),
      AdhanReciterEntity(
        id: 'dhuhr_fares',
        name: "فارس عباد",
        normalAdhanAssetPath: 'assets/aliiqama/fars_abad.mp3',
      ),
      AdhanReciterEntity(
        id: 'dhuhr_abdullah_sabaawe',
        name: "عبد الله الصباوي",
        normalAdhanAssetPath: 'assets/aliiqama/Abdulah_Al_Sabaawe.mp3',
      ),
      AdhanReciterEntity(
        id: 'dhuhr_abdulrahman_majde',
        name: "عبد الرحمن ماجد",
        normalAdhanAssetPath: 'assets/aliiqama/Abdul_Rahman_Majde.mp3',
      ),
      AdhanReciterEntity(
        id: 'dhuhr_abdulrahman_arake',
        name: "عبد الرحمن العراقي",
        normalAdhanAssetPath: 'assets/aliiqama/Abdul_Rahman_Al_Arake_3.mp3',
      ),
      AdhanReciterEntity(
        id: 'dhuhr_abdulmajid_surehi',
        name: "عبد المجيد السريحي",
        normalAdhanAssetPath: 'assets/aliiqama/Abdul_Majid_Al_Surehi_3.mp3',
      ),
      AdhanReciterEntity(
        id: 'dhuhr_gado',
        name: "بديع جادو",
        normalAdhanAssetPath: 'assets/aliiqama/badih_gado.mp3',
      ),
    ],
    'asr': [
      AdhanReciterEntity(
        id: 'asr_yasser',
        name: 'ياسر الدوسري',
        normalAdhanAssetPath: 'assets/aliiqama/Yasser_Al-Dosari_-_Saudi_Arabia.mp3',
      ),
      AdhanReciterEntity(
        id: 'asr_naser',
        name: 'ناصر القطامي',
        normalAdhanAssetPath: 'assets/aliiqama/naser_alqtame.mp3',
      ),
      AdhanReciterEntity(
        id: 'asr_abdulbasit',
        name: "عبد الباسط",
        normalAdhanAssetPath: 'assets/aliiqama/Abdulbasit_Abdusamad_3.mp3',
      ),
      AdhanReciterEntity(
        id: 'asr_fares',
        name: "فارس عباد",
        normalAdhanAssetPath: 'assets/aliiqama/fars_abad.mp3',
      ),
      AdhanReciterEntity(
        id: 'asr_abdullah_sabaawe',
        name: "عبد الله الصباوي",
        normalAdhanAssetPath: 'assets/aliiqama/Abdulah_Al_Sabaawe.mp3',
      ),
      AdhanReciterEntity(
        id: 'asr_abdulrahman_majde',
        name: "عبد الرحمن ماجد",
        normalAdhanAssetPath: 'assets/aliiqama/Abdul_Rahman_Majde.mp3',
      ),
      AdhanReciterEntity(
        id: 'asr_abdulrahman_arake',
        name: "عبد الرحمن العراقي",
        normalAdhanAssetPath: 'assets/aliiqama/Abdul_Rahman_Al_Arake_3.mp3',
      ),
      AdhanReciterEntity(
        id: 'asr_abdulmajid_surehi',
        name: "عبد المجيد السريحي",
        normalAdhanAssetPath: 'assets/aliiqama/Abdul_Majid_Al_Surehi_3.mp3',
      ),
      AdhanReciterEntity(
        id: 'asr_gado',
        name: "بديع جادو",
        normalAdhanAssetPath: 'assets/aliiqama/badih_gado.mp3',
      ),
    ],
    'maghrib': [
      AdhanReciterEntity(
        id: 'maghrib_yasser',
        name: 'ياسر الدوسري',
        normalAdhanAssetPath: 'assets/aliiqama/Yasser_Al-Dosari_-_Saudi_Arabia.mp3',
      ),
      AdhanReciterEntity(
        id: 'maghrib_naser',
        name: 'ناصر القطامي',
        normalAdhanAssetPath: 'assets/aliiqama/naser_alqtame.mp3',
      ),
      AdhanReciterEntity(
        id: 'maghrib_abdulbasit',
        name: "عبد الباسط",
        normalAdhanAssetPath: 'assets/aliiqama/Abdulbasit_Abdusamad_3.mp3',
      ),
      AdhanReciterEntity(
        id: 'maghrib_fares',
        name: "فارس عباد",
        normalAdhanAssetPath: 'assets/aliiqama/fars_abad.mp3',
      ),
      AdhanReciterEntity(
        id: 'maghrib_abdullah_sabaawe',
        name: "عبد الله الصباوي",
        normalAdhanAssetPath: 'assets/aliiqama/Abdulah_Al_Sabaawe.mp3',
      ),
      AdhanReciterEntity(
        id: 'maghrib_abdulrahman_majde',
        name: "عبد الرحمن ماجد",
        normalAdhanAssetPath: 'assets/aliiqama/Abdul_Rahman_Majde.mp3',
      ),
      AdhanReciterEntity(
        id: 'maghrib_abdulrahman_arake',
        name: "عبد الرحمن العراقي",
        normalAdhanAssetPath: 'assets/aliiqama/Abdul_Rahman_Al_Arake_3.mp3',
      ),
      AdhanReciterEntity(
        id: 'maghrib_abdulmajid_surehi',
        name: "عبد المجيد السريحي",
        normalAdhanAssetPath: 'assets/aliiqama/Abdul_Majid_Al_Surehi_3.mp3',
      ),
      AdhanReciterEntity(
        id: 'maghrib_gado',
        name: "بديع جادو",
        normalAdhanAssetPath: 'assets/aliiqama/badih_gado.mp3',
      ),
    ],
    'isha': [
      AdhanReciterEntity(
        id: 'isha_yasser',
        name: 'ياسر الدوسري',
        normalAdhanAssetPath: 'assets/aliiqama/Yasser_Al-Dosari_-_Saudi_Arabia.mp3',
      ),
      AdhanReciterEntity(
        id: 'isha_naser',
        name: 'ناصر القطامي',
        normalAdhanAssetPath: 'assets/aliiqama/naser_alqtame.mp3',
      ),
      AdhanReciterEntity(
        id: 'isha_abdulbasit',
        name: "عبد الباسط",
        normalAdhanAssetPath: 'assets/aliiqama/Abdulbasit_Abdusamad_3.mp3',
      ),
      AdhanReciterEntity(
        id: 'isha_fares',
        name: "فارس عباد",
        normalAdhanAssetPath: 'assets/aliiqama/fars_abad.mp3',
      ),
      AdhanReciterEntity(
        id: 'isha_abdullah_sabaawe',
        name: "عبد الله الصباوي",
        normalAdhanAssetPath: 'assets/aliiqama/Abdulah_Al_Sabaawe.mp3',
      ),
      AdhanReciterEntity(
        id: 'isha_abdulrahman_majde',
        name: "عبد الرحمن ماجد",
        normalAdhanAssetPath: 'assets/aliiqama/Abdul_Rahman_Majde.mp3',
      ),
      AdhanReciterEntity(
        id: 'isha_abdulrahman_arake',
        name: "عبد الرحمن العراقي",
        normalAdhanAssetPath: 'assets/aliiqama/Abdul_Rahman_Al_Arake_3.mp3',
      ),
      AdhanReciterEntity(
        id: 'isha_abdulmajid_surehi',
        name: "عبد المجيد السريحي",
        normalAdhanAssetPath: 'assets/aliiqama/Abdul_Majid_Al_Surehi_3.mp3',
      ),
      AdhanReciterEntity(
        id: 'isha_gado',
        name: "بديع جادو",
        normalAdhanAssetPath: 'assets/aliiqama/badih_gado.mp3',
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