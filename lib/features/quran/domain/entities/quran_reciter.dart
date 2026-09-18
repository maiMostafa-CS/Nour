class QuranReciter {
  final String identifier;
  final String name;
  final String englishName;
  final int bitrate;

  const QuranReciter({
    required this.identifier,
    required this.name,
    required this.englishName,
    this.bitrate = 128,
  });
}