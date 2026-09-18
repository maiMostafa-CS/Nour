import '../entities/quran_tafsir.dart';
import '../entities/quran_tafsir_book.dart';


abstract class TafsirBooksRepository {
Future<List<QuranTafsirBook>> getTafsirBooks({
  required int surahNumber,
});

Future<QuranTafsir?> getAyahTafsir({
  required int surahNumber,
  required int ayahNumber,
  required int bookId,
});}