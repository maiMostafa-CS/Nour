import '../entities/quran_reciter.dart';

abstract class QuranAudioRepository {

  List<QuranReciter> getReciters();

  String getAyahAudioUrl({
    required String reciterIdentifier,
    required int globalAyahNumber,
  });
}
