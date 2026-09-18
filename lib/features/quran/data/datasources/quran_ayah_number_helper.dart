abstract class QuranAudioRemoteDataSource {
  String getAyahAudioUrl({
    required String reciterIdentifier,
    required int globalAyahNumber,
    int bitrate = 128,
  });
}

class QuranAudioRemoteDataSourceImpl implements QuranAudioRemoteDataSource {
  static const String _baseUrl = 'https://cdn.islamic.network/quran/audio';

  @override
  String getAyahAudioUrl({
    required String reciterIdentifier,
    required int globalAyahNumber,
    int bitrate = 128,
  }) {
    final url = '$_baseUrl/$bitrate/$reciterIdentifier/$globalAyahNumber.mp3';

    print('══════════════════════════════════');
    print('🎧 Reciter Identifier : $reciterIdentifier');
    print('🔢 Global Ayah Number : $globalAyahNumber');
    print('🎚️ Bitrate            : $bitrate');
    print('🔗 Final URL          : $url');
    print('══════════════════════════════════');

    return url;
  }
}