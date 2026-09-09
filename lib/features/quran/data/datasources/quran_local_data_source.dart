import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/surah_entity.dart';

abstract class QuranLocalDataSource {
  Future<List<SurahEntity>> getSurahs();
}

class QuranLocalDataSourceImpl implements QuranLocalDataSource {
  @override
  Future<List<SurahEntity>> getSurahs() async {
    try {
      print('📖 بدء تحميل ملف القرآن...');

      final raw = await rootBundle.loadString(
        'assets/quran/quran.json',
      );

      print('✅ تم قراءة ملف quran.json');
      print('📦 حجم الملف: ${raw.length} حرف');

      final decoded = jsonDecode(raw);

      print('✅ تم تحويل JSON بنجاح');
      print('🔍 نوع البيانات: ${decoded.runtimeType}');

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'صيغة quran.json غير صحيحة',
        );
      }

      print('📖 عدد السور في JSON: ${decoded.length}');

      final surahs = <SurahEntity>[];

      for (final entry in decoded.entries) {
        final surahNumber = int.parse(entry.key);

        final ayahsData = entry.value as List;

        print(
          '🔄 معالجة سورة رقم $surahNumber '
              '- عدد الآيات: ${ayahsData.length}',
        );

        final ayahs = ayahsData.map((a) {
          return AyahEntity(
            number: a['verse'] as int,
            text: a['text'] as String,
          );
        }).toList();

        final surah = SurahEntity(
          number: surahNumber,
          name: _getSurahName(surahNumber),
          englishName: _getEnglishSurahName(surahNumber),
          ayahs: ayahs,
        );

        surahs.add(surah);

        print(
          '✅ سورة ${surah.number}: '
              '${surah.name} - '
              'عدد الآيات: ${surah.ayahs.length}',
        );
      }

      surahs.sort(
            (a, b) => a.number.compareTo(b.number),
      );

      final totalAyahs = surahs.fold<int>(
        0,
            (sum, surah) => sum + surah.ayahs.length,
      );

      print('================================');
      print('🎉 تم تحميل القرآن بنجاح');
      print('📖 عدد السور: ${surahs.length}');
      print('📖 إجمالي الآيات: $totalAyahs');
      print('================================');

      return surahs;
    } catch (e, stackTrace) {
      print('❌ ERROR أثناء تحميل القرآن');
      print('❌ النوع: ${e.runtimeType}');
      print('❌ الرسالة: $e');
      print('📍 StackTrace:');
      print(stackTrace);

      rethrow;
    }
  }

  String _getSurahName(int number) {
    const names = [
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

    return names[number - 1];
  }

  String _getEnglishSurahName(int number) {
    const names = [
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
      'Ta-Ha',
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
      'Al-Jumah',
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

    return names[number - 1];
  }
}