import 'package:flutter/services.dart';

import '../domain/entities/khatma_progress.dart';


class KhatmaUnlockSyncService {
  KhatmaUnlockSyncService._();

  static const MethodChannel _channel =
  MethodChannel(
    'com.example.islamic_app/khatma',
  );

  static Future<void> saveCurrentAyah(
      KhatmaUnlockAyah ayah,
      ) async {
    await _channel.invokeMethod(
      'saveCurrentAyah',
      {
        'globalNumber': ayah.globalNumber,
        'surahNumber': ayah.surahNumber,
        'ayahNumber': ayah.ayahNumber,
        'surahName': ayah.surahName,
        'text': ayah.text,
        'pageNumber': ayah.pageNumber,
      },
    );
  }

  static void setKhatmaReadHandler(
      Future<void> Function() onRead,
      ) {
    _channel.setMethodCallHandler(
          (call) async {
        if (call.method == 'markCurrentAyahAsRead') {
          await onRead();
        }
      },
    );
  }
}