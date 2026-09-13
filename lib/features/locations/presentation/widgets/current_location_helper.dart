import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CurrentLocationHelper {
  static Future<bool> checkAndRequestPermission(
      BuildContext context,
      ) async {
    try {
      final serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      debugPrint(
        '📍 GPS SERVICE ENABLED = $serviceEnabled',
      );

      if (!serviceEnabled) {
        if (!context.mounted) return false;

        await showLocationServiceDialog(context);
        return false;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      debugPrint(
        '📍 LOCATION PERMISSION BEFORE = $permission',
      );

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();

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

      if (permission ==
          LocationPermission.deniedForever) {
        if (!context.mounted) return false;

        await showPermissionSettingsDialog(context);
        return false;
      }

      debugPrint('📍 LOCATION READY');

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

  static Future<void> showLocationServiceDialog(
      BuildContext context,
      ) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.location_off),
          title: const Text('الموقع غير مفعّل'),
          content: const Text(
            'يرجى تفعيل الموقع/GPS على جهازك '
                'قبل المتابعة.',
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

                await Geolocator.openLocationSettings();
              },
              child: const Text('فتح الإعدادات'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showPermissionSettingsDialog(
      BuildContext context,
      ) async {
    await showDialog(
      context: context,
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