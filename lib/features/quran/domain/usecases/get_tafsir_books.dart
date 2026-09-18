import '../entities/quran_tafsir_book.dart';
import '../repositories/tafsir_books_repository.dart';

class GetTafsirBooks {
  final TafsirBooksRepository repository;

  GetTafsirBooks(this.repository);

  Future<List<QuranTafsirBook>> call({
    required int surahNumber,
  }) {
    return repository.getTafsirBooks(
      surahNumber: surahNumber,
    );
  }
}