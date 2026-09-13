import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/config/prayer_scheduler_config.dart';

Future<void> saveLocation(
    BuildContext context, {
      required double latitude,
      required double longitude,
      required String city,
      required String country,
      required String timezone,
      required bool isCurrentLocation,
    })
async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(
    'prayer_location_mode',
    isCurrentLocation ? 'auto' : 'manual',
  );

  if (isCurrentLocation) {
    await prefs.setDouble(
      'prayer_current_latitude',
      latitude,
    );

    await prefs.setDouble(
      'prayer_current_longitude',
      longitude,
    );
  } else {
    await prefs.setDouble(
      'prayer_manual_latitude',
      latitude,
    );

    await prefs.setDouble(
      'prayer_manual_longitude',
      longitude,
    );
  }

  await prefs.setString(
    'prayer_city_name',
    city,
  );

  await prefs.setString(
    'prayer_country_name',
    country,
  );

  if (timezone.isNotEmpty) {
    await prefs.setString(
      'prayer_location_timezone',
      timezone,
    );
  }

  // آخر موقع مستخدم فعليًا
  await prefs.setDouble(
    prayerLastLatitudePrefsKey,
    latitude,
  );

  await prefs.setDouble(
    prayerLastLongitudePrefsKey,
    longitude,
  );

  debugPrint(
    '📍 LOCATION SAVED | '
        'mode=${isCurrentLocation ? 'auto' : 'manual'} | '
        'city=$city | '
        'country=$country | '
        'lat=$latitude | '
        'lng=$longitude',
  );

  if (!context.mounted) return;

  Navigator.of(context).pushNamedAndRemoveUntil(
    '/',
        (route) => false,
  );
}