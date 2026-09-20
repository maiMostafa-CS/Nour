import 'package:equatable/equatable.dart';

class KhatmaProgress extends Equatable {
  static const int totalAyahs = 6236;

  final int currentAyah;
  final int readAyahs;

  const KhatmaProgress({
    required this.currentAyah,
    required this.readAyahs,
  });

  int get remainingAyahs {
    final remaining = totalAyahs - readAyahs;
    return remaining < 0 ? 0 : remaining;
  }

  double get progress {
    final value = readAyahs / totalAyahs;

    if (value < 0) return 0;
    if (value > 1) return 1;

    return value;
  }

  bool get isCompleted {
    return readAyahs >= totalAyahs;
  }

  @override
  List<Object?> get props => [
    currentAyah,
    readAyahs,
  ];
}

class KhatmaUnlockAyah extends Equatable {
  final int globalNumber;
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String text;
  final int pageNumber;

  const KhatmaUnlockAyah({
    required this.globalNumber,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.text,
    required this.pageNumber,
  });

  @override
  List<Object?> get props => [
    globalNumber,
    surahNumber,
    ayahNumber,
    surahName,
    text,
    pageNumber,
  ];
}