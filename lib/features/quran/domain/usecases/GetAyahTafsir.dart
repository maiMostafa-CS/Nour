import '../entities/quran_tafsir.dart';
import '../repositories/quran_repository.dart';
import '../repositories/tafsir_books_repository.dart';

class GetAyahTafsir {
  final TafsirBooksRepository repository;

  GetAyahTafsir(this.repository);

  Future<QuranTafsir?> call({
    required int surahNumber,
    required int ayahNumber,
    required int bookId,
  }) {
    return repository.getAyahTafsir(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      bookId: bookId,
    );
  }
}