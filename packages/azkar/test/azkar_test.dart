import 'package:flutter_test/flutter_test.dart';
import 'package:azkar/azkar.dart';

void main() {
  test('fetches categories for arabic language', () {
    final categories = Azkar.getCategories(AzkarLang.arabic);
    expect(categories, isNotEmpty);
  });

  test('fetches chapters for arabic language', () {
    final chapters = Azkar.getChapters(AzkarLang.arabic);
    expect(chapters, isNotEmpty);
  });
}
