import 'package:easy_localization/easy_localization.dart';
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
          'location_permission_required'.tr(),
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
// 3. User returned from Settings
//    Check again
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
            'enable_location_retry'.tr(),
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
        'location_update_failed'.tr(),
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
          title: Text('location_disabled_title'.tr()),
          content: Text(
            'location_disabled_content'.tr(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext, true);

                await Geolocator.openLocationSettings();
              },
              child: Text('open_settings'.tr()),
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
          title: Text(
            'location_permission_required'.tr(),
          ),
          content: Text(
            'permission_denied_forever'.tr(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await Geolocator.openAppSettings();
              },
              child: Text('open_settings'.tr()),
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
