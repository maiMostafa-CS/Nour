import '../repositories/quran_audio_repository.dart';

class GetAyahAudioUrl {
final QuranAudioRepository repository;

const GetAyahAudioUrl(this.repository);

String call({
required String reciterIdentifier,
required int globalAyahNumber,
}) {
return repository.getAyahAudioUrl(
reciterIdentifier: reciterIdentifier,
globalAyahNumber: globalAyahNumber,
);
}
}
