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