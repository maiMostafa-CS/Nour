import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'khatma_ayah_resolver.dart';

class KhatmaNotificationService {
  KhatmaNotificationService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const channelId = 'khatma_ayah';
  static const channelName = 'الختمة';
  static const notificationId = 46001;

  static const actionRead = 'khatma_read';
  static const actionLater = 'khatma_later';

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _notifications.initialize(
      settings: const InitializationSettings(android: android),
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        channelName,
        description: 'آيات الختمة',
        importance: Importance.high,
      ),
    );
  }

  static Future<void> showCurrentAyah() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('khatma_current_ayah') ?? 1;

    if (current > 6236) return;

    final ayah = KhatmaAyahResolver.resolve(current);

    await initialize();

    final details = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'آية الختمة الحالية',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: false,
      styleInformation: BigTextStyleInformation(
        ayah.text,
        contentTitle: '🌿 آية الختمة',
        summaryText: '${ayah.surahName} • آية ${ayah.ayahNumber}',
      ),
      actions: const [
        AndroidNotificationAction(
          actionRead,
          'قرأتها ✓',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          actionLater,
          'لاحقًا',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );
    debugPrint('═══════════════════════════════════════');
    debugPrint('🌿 KHATMA NOTIFICATION TEST');
    debugPrint('📖 Global Ayah: ${ayah.globalNumber}');
    debugPrint('📕 Surah: ${ayah.surahName}');
    debugPrint('🔢 Ayah: ${ayah.ayahNumber}');
    debugPrint('📄 Page: ${ayah.pageNumber}');
    debugPrint('═══════════════════════════════════════');

  try{  await _notifications.show(
      id: notificationId,
      title: '🌿 آية الختمة',
      body: '${ayah.surahName} • آية ${ayah.ayahNumber}',
      notificationDetails: NotificationDetails(
        android: details,
      ),
      payload: 'khatma:${ayah.globalNumber}:page:${ayah.pageNumber}',
    );
    debugPrint(
      '✅ KHATMA NOTIFICATION SHOW SUCCESS '
          '| id=$notificationId '
          '| ayah=${ayah.globalNumber} '
          '| page=${ayah.pageNumber}',
    );}catch (e, stackTrace) {
    debugPrint('❌ KHATMA NOTIFICATION FAILED: $e');
    debugPrint('$stackTrace');
  }
  }

  static Future<void> markCurrentAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('khatma_current_ayah') ?? 1;
    final read = prefs.getInt('khatma_read_ayahs') ?? 0;

    if (current <= 6236) {
      await prefs.setInt('khatma_current_ayah', current + 1);
      await prefs.setInt('khatma_read_ayahs', read + 1);
    }
  }

  static Future<void> keepCurrent() async {}

  static Future<void> handleAction(String actionId) async {
    if (actionId == actionRead) {
      await markCurrentAsRead();
    } else if (actionId == actionLater) {
      await keepCurrent();
    }
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  await KhatmaNotificationService.handleAction(response.actionId ?? '');
}
