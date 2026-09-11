import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

Future<bool> showCurrentLocationDialog(
    BuildContext context,
    )
async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        icon: Icon(
          Icons.location_on,
          size: 42.sp,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          'Update Current Location',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.sp,
          ),
        ),
        content: Text(
          'Your current location will be updated.\n\n'
              'Please make sure that Location/GPS is enabled '
              'on your device.\n\n'
              'If Location is disabled, please enable it '
              'before continuing.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.sp,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: Text(
              'Update Location',
              style: TextStyle(
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      );
    },
  );

  return result == true;
}


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
          'Location permission is required.',
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
        'Unable to access your location.',
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
          title: const Text('Location Disabled'),
          content: const Text(
            'Please enable Location/GPS on your device '
                'before continuing.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await Geolocator.openLocationSettings();
              },
              child: const Text('Open Settings'),
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
            'Location Permission Required',
          ),
          content: const Text(
            'Location permission has been permanently denied. '
                'Please enable it from the application settings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await Geolocator.openAppSettings();
              },
              child: const Text('Open Settings'),
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