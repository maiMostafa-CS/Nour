class QuranTafsir {
  final int bookId;
  final String bookName;
  final String? author;
  final String text;

  const QuranTafsir({
    required this.bookId,
    required this.bookName,
    this.author,
    required this.text,
  });
}