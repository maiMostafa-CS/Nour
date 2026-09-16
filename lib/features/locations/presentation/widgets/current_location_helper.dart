import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CurrentLocationHelper {
  static Future<bool> checkAndRequestPermission(
    BuildContext context,
  ) async {
    try {
// ============================================================
// 1. PERMISSION
// ============================================================

      LocationPermission permission = await Geolocator.checkPermission();

      debugPrint(
        '📍 LOCATION PERMISSION BEFORE = $permission',
      );

      if (permission == LocationPermission.denied) {
        debugPrint('📍 REQUESTING LOCATION PERMISSION...');

        permission = await Geolocator.requestPermission();

        debugPrint(
          '📍 LOCATION PERMISSION AFTER = $permission',
        );
      }

      if (permission == LocationPermission.denied) {
        if (!context.mounted) return false;

        showMessage(
          context,
          'يلزم السماح بالوصول إلى الموقع.',
        );

        return false;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!context.mounted) return false;

        await showPermissionSettingsDialog(context);

        return false;
      }

// ============================================================
// 2. LOCATION SERVICE / GPS
// ============================================================

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      debugPrint(
        '📍 GPS SERVICE ENABLED = $serviceEnabled',
      );

      if (!serviceEnabled) {
        if (!context.mounted) return false;

        final opened = await showLocationServiceDialog(context);

        if (!opened) {
          return false;
        }

// ========================================================
// 3. المستخدم رجع من Settings
//    نتحقق مرة أخرى
// ========================================================

        serviceEnabled = await Geolocator.isLocationServiceEnabled();

        debugPrint(
          '📍 GPS SERVICE AFTER SETTINGS = '
          '$serviceEnabled',
        );

        if (!serviceEnabled) {
          if (!context.mounted) return false;

          showMessage(
            context,
            'يرجى تفعيل الموقع ثم المحاولة مرة أخرى.',
          );

          return false;
        }
      }

      debugPrint('✅ LOCATION READY');

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        '❌ LOCATION PERMISSION CHECK FAILED',
      );

      debugPrint('❌ ERROR = $e');
      debugPrint('❌ STACK = $stackTrace');

      if (!context.mounted) return false;

      showMessage(
        context,
        'تعذر الوصول إلى موقعك.',
      );

      return false;
    }
  }

// ==============================================================
// LOCATION SERVICE DIALOG
// ==============================================================

  static Future<bool> showLocationServiceDialog(
    BuildContext context,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.location_off),
          title: const Text('الموقع غير مفعّل'),
          content: const Text(
            'يحتاج التطبيق إلى تفعيل الموقع/GPS '
            'للحصول على موقعك الحالي.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext, true);

                await Geolocator.openLocationSettings();
              },
              child: const Text('فتح الإعدادات'),
            ),
          ],
        );
      },
    );

    return result == true;
  }

// ==============================================================
// PERMISSION SETTINGS
// ==============================================================

  static Future<void> showPermissionSettingsDialog(
    BuildContext context,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.location_disabled),
          title: const Text(
            'يلزم السماح بالموقع',
          ),
          content: const Text(
            'تم رفض إذن الموقع بشكل دائم. '
            'يرجى تفعيله من إعدادات التطبيق.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await Geolocator.openAppSettings();
              },
              child: const Text('فتح الإعدادات'),
            ),
          ],
        );
      },
    );
  }

// ==============================================================
// MESSAGE
// ==============================================================

  static void showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
