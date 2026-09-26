// lib/features/adhan/presentation/services/adhan_preview_player.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Service مسؤول عن تشغيل preview للمذنين.
/// بيعزل الـ AudioPlayer عن الـ Widget عشان الكود يبقى أنضف.
class AdhanPreviewPlayer {
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<PlayerState>? _stateSub;

  /// الـ callback بيتنادى لما الصوت يخلص
  VoidCallback? onCompleted;

  /// الـ ID اللي شغال حالياً (أو null)
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

  /// شغّل معرّف معين، أو وقّف اللي شغال.
  /// بيرجّع true لو بدأ تشغيل جديد، false لو وقف.
  Future<bool> toggle({
    required String id,
    required String assetPath,
  }) async {
    // لو نفس اللي شغال → وقّف
    if (_currentId == id) {
      await stop();
      return false;
    }

    try {
      await _player.stop();
      await _player.setAsset(assetPath);

      _currentId = id;
      // 🚨 مهم: unawaited عشان play() بتستنى لحد ما الصوت يخلص
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