// lib/features/tasbih/data/tasbih_data.dart

import '../models/tasbih_model.dart';

class TasbihData {
  static const int targetCount = 100;

  static const List<TasbihDhikr> defaultAdhkar = [
    TasbihDhikr(
      id: 1,
      text: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ ﷺ',
      virtue: 'من صلى عليّ صلاة صلى الله عليه بها عشراً',
      targetCount: 100,
    ),
    TasbihDhikr(
      id: 2,
      text: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      virtue: 'من لزم الاستغفار جعل الله له من كل هم فرجاً',
      targetCount: 100,
    ),
    TasbihDhikr(
      id: 3,
      text:
      'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      virtue: 'من قالها مائة مرة كانت له عدل عشر رقاب',
      targetCount: 100,
    ),
    TasbihDhikr(
      id: 4,
      text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      virtue: 'من قالها مائة مرة حُطَّت خطاياه وإن كانت مثل زبد البحر',
      targetCount: 100,
    ),
    TasbihDhikr(
      id: 5,
      text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      virtue:
      'كلمتان خفيفتان على اللسان، ثقيلتان في الميزان، حبيبتان إلى الرحمن',
      targetCount: 100,
    ),
    TasbihDhikr(
      id: 6,
      text: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      virtue: 'كنز من كنوز الجنة',
      targetCount: 100,
    ),
  ];

  static const List<TasbihDhikr> adhkar = defaultAdhkar;

  // ✨ خيارات سريعة للعدد المستهدف
  static const List<int> targetPresets = [10, 33, 50, 100, 500, 1000];
}