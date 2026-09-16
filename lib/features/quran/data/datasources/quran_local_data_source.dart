import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/surah_entity.dart';

abstract class QuranPagesDataSource {
Future<List<SurahEntity>> getSurahs();

Future<PageEntity> getPage(int pageNumber);
}

class QuranPagesDataSourceImpl implements QuranPagesDataSource {
static const String _jsonPath = 'assets/quran/quran.json';

Map<String, dynamic>? _cache;

// ============================================================
// تحميل JSON
// ============================================================

Future<Map<String, dynamic>> _loadJson() async {
if (_cache != null) {
return _cache!;
}

final jsonString = await rootBundle.loadString(_jsonPath);

final decoded = jsonDecode(jsonString);

if (decoded is! Map) {
throw Exception('quran.json غير صالح');
}

_cache = Map<String, dynamic>.from(decoded);

return _cache!;
}

// ============================================================
// السور
// ============================================================

@override
Future<List<SurahEntity>> getSurahs() async {
final data = await _loadJson();

/*
     * ملف quran.json يحتوي على:
     *
     * "surahs": [
     *   {
     *     "number": 1,
     *     "file": "s001.json",
     *     "verses_count": 7
     *   },
     *   ...
     * ]
     *
     * لكن أسماء السور غير موجودة هنا.
     *
     * لذلك نستخدم أسماء السور المعروفة
     * ونستخرج عدد الآيات من JSON.
     */

final rawSurahs = data['surahs'];

if (rawSurahs is! List) {
throw Exception('لم يتم العثور على surahs داخل quran.json');
}

final names = _surahNames;

final result = <SurahEntity>[];

for (final item in rawSurahs) {
if (item is! Map) continue;

final number = _toInt(item['number']);

if (number <= 0 || number >= names.length) {
continue;
}

final totalAyahs = _toInt(item['verses_count']);

result.add(
SurahEntity(
number: number,
name: names[number],
englishName: _englishSurahNames[number],
startPage: _getSurahStartPage(
data,
number,
),
totalAyahs: totalAyahs,
),
);
}

return result;
}

// ============================================================
// صفحة واحدة
// ============================================================

@override
Future<PageEntity> getPage(int pageNumber) async {
if (pageNumber < 1 || pageNumber > 604) {
throw ArgumentError(
'رقم الصفحة يجب أن يكون بين 1 و604',
);
}

final data = await _loadJson();

final pages = data['pages'];

if (pages is! Map) {
throw Exception(
'لم يتم العثور على pages داخل quran.json',
);
}

/*
     * الصفحة في JSON تكون بهذا الشكل:
     *
     * "1": {
     *   "page": 1,
     *   "juz": 1,
     *   "verses": [...]
     * }
     */

final rawPage = pages[pageNumber.toString()];

if (rawPage is! Map) {
throw Exception(
'الصفحة $pageNumber غير موجودة في quran.json',
);
}

final rawVerses = rawPage['verses'];

if (rawVerses is! List) {
throw Exception(
'لم يتم العثور على verses في الصفحة $pageNumber',
);
}

final ayahs = <AyahEntity>[];

for (final item in rawVerses) {
if (item is! Map) {
continue;
}

final verse = Map<String, dynamic>.from(item);

final surahNumber = _toInt(
verse['surah'],
);

final ayahNumber = _toInt(
verse['ayah'],
);

final text = (verse['text'] ?? '').toString();

final translation = verse['translation_en']?.toString();

final juz = _toInt(
verse['juz'] ?? rawPage['juz'],
);

final hizb = _toNullableInt(
verse['hizb'],
);

final rub = _toNullableInt(
verse['rub'],
);

final page = _toInt(
verse['page'] ?? pageNumber,
);

final ruku = _toNullableInt(
verse['ruku'],
);

/*
       * لا نضيف الآية إذا كان النص فارغًا.
       */

if (text.trim().isEmpty) {
continue;
}

ayahs.add(
AyahEntity(
surahNumber: surahNumber,
ayahNumber: ayahNumber,
text: text,
translation: translation,
juz: juz,
hizb: hizb,
rub: rub,
page: page,
ruku: ruku,
),
);
}

if (ayahs.isEmpty) {
throw Exception(
'الصفحة $pageNumber لا تحتوي على آيات',
);
}

return PageEntity(
pageNumber: pageNumber,
ayahs: ayahs,
);
}

// ============================================================
// تحديد أول صفحة للسورة
// ============================================================

int _getSurahStartPage(
Map<String, dynamic> data,
int surahNumber,
) {
final pages = data['pages'];

if (pages is! Map) {
return 1;
}

for (final entry in pages.entries) {
final rawPage = entry.value;

if (rawPage is! Map) {
continue;
}

final verses = rawPage['verses'];

if (verses is! List) {
continue;
}

for (final verse in verses) {
if (verse is! Map) {
continue;
}

final verseSurah = _toInt(
verse['surah'],
);

final verseAyah = _toInt(
verse['ayah'],
);

if (verseSurah == surahNumber && verseAyah == 1) {
return _toInt(
rawPage['page'] ?? entry.key,
);
}
}
}

return 1;
}

// ============================================================
// تحويل إلى int
// ============================================================

int _toInt(dynamic value) {
if (value is int) {
return value;
}

if (value is num) {
return value.toInt();
}

return int.tryParse(
value?.toString() ?? '',
) ??
0;
}

// ============================================================
// تحويل إلى int nullable
// ============================================================

int? _toNullableInt(dynamic value) {
if (value == null) {
return null;
}

if (value is int) {
return value;
}

if (value is num) {
return value.toInt();
}

return int.tryParse(
value.toString(),
);
}

// ============================================================
// أسماء السور
// ============================================================

static const List<String> _surahNames = [
'',
'الفاتحة',
'البقرة',
'آل عمران',
'النساء',
'المائدة',
'الأنعام',
'الأعراف',
'الأنفال',
'التوبة',
'يونس',
'هود',
'يوسف',
'الرعد',
'إبراهيم',
'الحجر',
'النحل',
'الإسراء',
'الكهف',
'مريم',
'طه',
'الأنبياء',
'الحج',
'المؤمنون',
'النور',
'الفرقان',
'الشعراء',
'النمل',
'القصص',
'العنكبوت',
'الروم',
'لقمان',
'السجدة',
'الأحزاب',
'سبأ',
'فاطر',
'يس',
'الصافات',
'ص',
'الزمر',
'غافر',
'فصلت',
'الشورى',
'الزخرف',
'الدخان',
'الجاثية',
'الأحقاف',
'محمد',
'الفتح',
'الحجرات',
'ق',
'الذاريات',
'الطور',
'النجم',
'القمر',
'الرحمن',
'الواقعة',
'الحديد',
'المجادلة',
'الحشر',
'الممتحنة',
'الصف',
'الجمعة',
'المنافقون',
'التغابن',
'الطلاق',
'التحريم',
'الملك',
'القلم',
'الحاقة',
'المعارج',
'نوح',
'الجن',
'المزمل',
'المدثر',
'القيامة',
'الإنسان',
'المرسلات',
'النبأ',
'النازعات',
'عبس',
'التكوير',
'الانفطار',
'المطففين',
'الانشقاق',
'البروج',
'الطارق',
'الأعلى',
'الغاشية',
'الفجر',
'البلد',
'الشمس',
'الليل',
'الضحى',
'الشرح',
'التين',
'العلق',
'القدر',
'البينة',
'الزلزلة',
'العاديات',
'القارعة',
'التكاثر',
'العصر',
'الهمزة',
'الفيل',
'قريش',
'الماعون',
'الكوثر',
'الكافرون',
'النصر',
'المسد',
'الإخلاص',
'الفلق',
'الناس',
];

// ============================================================
// الأسماء الإنجليزية
// ============================================================

static const List<String> _englishSurahNames = [
'',
'Al-Fatihah',
'Al-Baqarah',
'Aal-Imran',
'An-Nisa',
'Al-Maidah',
'Al-Anam',
'Al-Araf',
'Al-Anfal',
'At-Tawbah',
'Yunus',
'Hud',
'Yusuf',
'Ar-Rad',
'Ibrahim',
'Al-Hijr',
'An-Nahl',
'Al-Isra',
'Al-Kahf',
'Maryam',
'Taha',
'Al-Anbiya',
'Al-Hajj',
'Al-Muminun',
'An-Nur',
'Al-Furqan',
'Ash-Shuara',
'An-Naml',
'Al-Qasas',
'Al-Ankabut',
'Ar-Rum',
'Luqman',
'As-Sajdah',
'Al-Ahzab',
'Saba',
'Fatir',
'Ya-Sin',
'As-Saffat',
'Sad',
'Az-Zumar',
'Ghafir',
'Fussilat',
'Ash-Shura',
'Az-Zukhruf',
'Ad-Dukhan',
'Al-Jathiyah',
'Al-Ahqaf',
'Muhammad',
'Al-Fath',
'Al-Hujurat',
'Qaf',
'Adh-Dhariyat',
'At-Tur',
'An-Najm',
'Al-Qamar',
'Ar-Rahman',
'Al-Waqiah',
'Al-Hadid',
'Al-Mujadilah',
'Al-Hashr',
'Al-Mumtahanah',
'As-Saff',
'Al-Jumuah',
'Al-Munafiqun',
'At-Taghabun',
'At-Talaq',
'At-Tahrim',
'Al-Mulk',
'Al-Qalam',
'Al-Haqqah',
'Al-Maarij',
'Nuh',
'Al-Jinn',
'Al-Muzzammil',
'Al-Muddaththir',
'Al-Qiyamah',
'Al-Insan',
'Al-Mursalat',
'An-Naba',
'An-Naziat',
'Abasa',
'At-Takwir',
'Al-Infitar',
'Al-Mutaffifin',
'Al-Inshiqaq',
'Al-Buruj',
'At-Tariq',
'Al-Ala',
'Al-Ghashiyah',
'Al-Fajr',
'Al-Balad',
'Ash-Shams',
'Al-Layl',
'Ad-Duha',
'Ash-Sharh',
'At-Tin',
'Al-Alaq',
'Al-Qadr',
'Al-Bayyinah',
'Az-Zalzalah',
'Al-Adiyat',
'Al-Qariah',
'At-Takathur',
'Al-Asr',
'Al-Humazah',
'Al-Fil',
'Quraysh',
'Al-Maun',
'Al-Kawthar',
'Al-Kafirun',
'An-Nasr',
'Al-Masad',
'Al-Ikhlas',
'Al-Falaq',
'An-Nas',
];
}
