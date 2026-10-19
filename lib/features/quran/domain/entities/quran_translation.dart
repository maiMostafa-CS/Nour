class QuranTranslation {
  final int resourceId;
  final String translationName;
  final String authorName;
  final String text;
  final int? ayahNumber;

  const QuranTranslation({
    required this.resourceId,
    required this.translationName,
    required this.authorName,
    required this.text,
    this.ayahNumber,
  });
}
