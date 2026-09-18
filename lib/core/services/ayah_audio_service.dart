import 'package:just_audio/just_audio.dart';

class AyahAudioService {
final AudioPlayer _player = AudioPlayer();

String? _currentReciter;
int? _currentAyah;

bool get isPlaying => _player.playing;

String? get currentReciter => _currentReciter;

int? get currentAyah => _currentAyah;

Stream<bool> get playingStream =>
_player.playingStream;

Stream<PlayerState> get playerStateStream =>
_player.playerStateStream;

// ==========================================================
// PLAY URL
// ==========================================================
  Future<void> playUrl({
    required String audioUrl,
    required String reciterIdentifier,
    required int globalAyahNumber,
  }) async {
    _currentReciter = reciterIdentifier;
    _currentAyah = globalAyahNumber;

    try {
      await _player.setUrl(
        audioUrl,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Mobile Safari/537.36',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: setUrl took too long');
        },
      );

      await _player.play();
    } catch (e) {
      print('❌ setUrl/play error: $e');
      rethrow;
    }
  }
// ==========================================================
// PAUSE
// ==========================================================

Future<void> pause() async {
await _player.pause();
}

// ==========================================================
// RESUME
// ==========================================================

Future<void> resume() async {
await _player.play();
}

// ==========================================================
// STOP
// ==========================================================

Future<void> stop() async {

await _player.stop();

_currentReciter = null;
_currentAyah = null;
}

// ==========================================================
// DISPOSE
// ==========================================================

Future<void> dispose() async {
await _player.dispose();
}
}
