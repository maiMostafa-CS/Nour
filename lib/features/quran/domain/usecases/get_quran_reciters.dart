import '../entities/quran_reciter.dart';
import '../repositories/quran_audio_repository.dart';

class GetQuranReciters {
final QuranAudioRepository repository;

const GetQuranReciters(this.repository);

List<QuranReciter> call() {
  return repository.getReciters().cast<QuranReciter>();
}
}
