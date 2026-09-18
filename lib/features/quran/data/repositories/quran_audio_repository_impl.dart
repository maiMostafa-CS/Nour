
import 'package:flutter/cupertino.dart';

import '../../domain/entities/quran_reciter.dart';
import '../../domain/repositories/quran_audio_repository.dart';

import '../datasources/quran_ayah_number_helper.dart';
import '../model/quran_reciter_model.dart';

class QuranAudioRepositoryImpl implements QuranAudioRepository {
final QuranAudioRemoteDataSource remoteDataSource;

QuranAudioRepositoryImpl({
required this.remoteDataSource,
});

@override
List<QuranReciter> getReciters() {
  debugPrint('🎧 getReciters called → ${quranReciters.length} reciters');
  return quranReciters;
}

@override
String getAyahAudioUrl({
required String reciterIdentifier,
required int globalAyahNumber,
}) {
return remoteDataSource.getAyahAudioUrl(
reciterIdentifier: reciterIdentifier,
globalAyahNumber: globalAyahNumber,
);
}
}
