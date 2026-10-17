import 'package:flutter_test/flutter_test.dart';

import 'package:azkar/azkar.dart';

void main() {
  group('Azkar Tests', () {
    test('fetches categories for Arabic', () {
      final categories = Azkar.getCategories(AzkarLang.arabic);
      expect(categories, isNotEmpty);
      expect(categories.first.name, isNotEmpty);
    });

    test('fetches chapters for Arabic', () {
      final chapters = Azkar.getChapters(AzkarLang.arabic);
      expect(chapters, isNotEmpty);
    });

    test('fetches chapters by category', () {
      final categories = Azkar.getCategories(AzkarLang.arabic);
      if (categories.isNotEmpty) {
        final chapters =
            Azkar.getChaptersByCategory(AzkarLang.arabic, categories.first.id);
        expect(chapters, isA<List<ChapterCategory>>());
      }
    });

    test('fetches items by chapter', () {
      final chapters = Azkar.getChapters(AzkarLang.arabic);
      if (chapters.isNotEmpty) {
        final items =
            Azkar.getItemsByChapter(AzkarLang.arabic, chapters.first.id);
        expect(items, isA<List<ItemChapter>>());
      }
    });

    test('fetches about information', () {
      final about = Azkar.getAbout(AzkarLang.arabic);
      expect(about.introduction.title, isNotEmpty);
      expect(about.benefit.title, isNotEmpty);
    });
  });
}

