import 'hizb_data.dart';

int? getHizbNumber(int surah, int verse) {
  int? currentHizb;

  for (final boundary in hizbBoundaries) {
    if (surah > boundary.surah ||
        (surah == boundary.surah && verse >= boundary.verse)) {
      currentHizb = boundary.hizb;
    } else {
      break;
    }
  }

  return currentHizb;
}

int getGlobalAyahNumber(
    int surahNumber,
    int verseNumber,
    ) {
  // عدد الآيات في كل سورة بالترتيب
  const ayahCounts = <int>[
    7,
    286,
    200,
    176,
    120,
    165,
    206,
    75,
    129,
    109,
    123,
    111,
    43,
    52,
    99,
    128,
    111,
    110,
    98,
    135,
    112,
    78,
    118,
    64,
    77,
    227,
    93,
    88,
    69,
    60,
    34,
    30,
    73,
    54,
    45,
    83,
    182,
    88,
    75,
    85,
    54,
    53,
    89,
    59,
    37,
    35,
    38,
    29,
    18,
    45,
    60,
    49,
    62,
    55,
    78,
    96,
    29,
    22,
    24,
    13,
    14,
    11,
    11,
    18,
    12,
    12,
    30,
    52,
    52,
    44,
    28,
    28,
    20,
    56,
    40,
    31,
    50,
    40,
    46,
    42,
    29,
    19,
    36,
    25,
    22,
    17,
    19,
    26,
    30,
    20,
    15,
    21,
    11,
    8,
    8,
    19,
    5,
    8,
    8,
    11,
    11,
    8,
    3,
    9,
    5,
    4,
    7,
    3,
    6,
    3,
    5,
    4,
    5,
    6,
  ];

  if (surahNumber < 1 || surahNumber > 114) {
    throw ArgumentError(
      'رقم السورة غير صحيح: $surahNumber',
    );
  }

  final maxVerse = ayahCounts[surahNumber - 1];

  if (verseNumber < 1 || verseNumber > maxVerse) {
    throw ArgumentError(
      'رقم الآية غير صحيح: '
          '$surahNumber:$verseNumber '
          '(الحد الأقصى $maxVerse)',
    );
  }

  var globalNumber = 0;

  for (var i = 0; i < surahNumber - 1; i++) {
    globalNumber += ayahCounts[i];
  }

  globalNumber += verseNumber;

  return globalNumber;
}

