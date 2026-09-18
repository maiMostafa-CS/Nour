import '../../domain/entities/quran_tafsir.dart';
import '../../domain/entities/quran_tafsir_book.dart';
import '../../domain/repositories/tafsir_books_repository.dart';
import '../datasources/quranpedia_remote_data_source.dart';

class TafsirBooksRepositoryImpl extends TafsirBooksRepository {
  final  QuranpediaRemoteDataSource remoteDataSource;

   TafsirBooksRepositoryImpl({
    required this.remoteDataSource,
  });
  @override
  Future<List<QuranTafsirBook>> getTafsirBooks({
    required int surahNumber,
  }) {
    return remoteDataSource.getTafsirBooks(
      surahNumber: surahNumber,
    );
  }

  @override
  Future<QuranTafsir?> getAyahTafsir({
    required int surahNumber,
    required int ayahNumber,
    required int bookId,
  }) async {
    return await remoteDataSource.getAyahTafsir(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      bookId: bookId,
    );
  }
}