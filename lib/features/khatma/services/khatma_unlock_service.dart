import 'package:flutter/services.dart';

import '../domain/entities/khatma_progress.dart';

class KhatmaUnlockSyncService {
  KhatmaUnlockSyncService._();

  static const MethodChannel _channel = MethodChannel(
    'com.example.islamic_app/khatma',
  );

// ============================================================
// Save Current Ayah
// ============================================================

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

// ============================================================
// Save Weekly Khatma Report
// ============================================================

  static Future<void> saveWeeklyReport({
    required int totalAyahs,
    required int currentWeekAyahs,
    required int weekNumber,
  }) async {
    await _channel.invokeMethod(
      'saveWeeklyReport',
      {
        'totalAyahs': totalAyahs,
        'currentWeekAyahs': currentWeekAyahs,
        'weekNumber': weekNumber,
      },
    );
  }

// ============================================================
// Pending Read Flag
// ============================================================

  static Future<bool> hasPendingRead() async {
    final result = await _channel.invokeMethod<bool>(
      'hasPendingRead',
    );

    return result ?? false;
  }

  static Future<void> clearPendingRead() async {
    await _channel.invokeMethod('clearPendingRead');
  }

// ============================================================
// Native → Flutter
// ============================================================

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