// lib/features/adhan/presentation/services/adhan_preview_player.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Service responsible for playing reciter previews.
/// Keeps the AudioPlayer separate from the Widget for cleaner code.
class AdhanPreviewPlayer {
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<PlayerState>? _stateSub;

  /// The callback is called when the audio finishes
  VoidCallback? onCompleted;

  /// The currently playing ID (or null)
  String? _currentId;
  String? get currentId => _currentId;
  bool get isPlaying => _player.playing;

  AdhanPreviewPlayer() {
    _stateSub = _player.playerStateStream.listen(
          (state) {
        if (state.processingState == ProcessingState.completed) {
          _currentId = null;
          _player.stop();
          onCompleted?.call();
        }
      },
      onError: (e) {
        debugPrint('❌ [PreviewPlayer] stream error: $e');
      },
    );
  }

  /// Play a specific ID, or stop the currently playing one.
  /// Returns true if new playback started, false if it stopped.
  Future<bool> toggle({
    required String id,
    required String assetPath,
  }) async {
    // If the same item is playing → stop it
    if (_currentId == id) {
      await stop();
      return false;
    }

    try {
      await _player.stop();
      await _player.setAsset(assetPath);

      _currentId = id;
      // 🚨 Important: use unawaited because play() waits until the audio finishes
      unawaited(_player.play());

      return true;
    } catch (e, st) {
      debugPrint('❌ [PreviewPlayer] toggle error: $e');
      debugPrint('$st');
      _currentId = null;
      rethrow;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _currentId = null;
  }

  Future<void> dispose() async {
    await _stateSub?.cancel();
    _stateSub = null;
    await _player.dispose();
  }
}