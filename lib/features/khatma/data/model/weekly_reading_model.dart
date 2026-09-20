class WeeklyReadingModel {
  final String weekKey;
  final Set<int> ayahs;

  const WeeklyReadingModel({
    required this.weekKey,
    required this.ayahs,
  });

  int get ayahCount => ayahs.length;
}