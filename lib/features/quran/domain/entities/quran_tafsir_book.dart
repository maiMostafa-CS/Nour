class QuranTafsirBook {
  final int id;
  final String name;
  final String? shortName;
  final String? author;

  const QuranTafsirBook({
    required this.id,
    required this.name,
    this.shortName,
    this.author,
  });
}