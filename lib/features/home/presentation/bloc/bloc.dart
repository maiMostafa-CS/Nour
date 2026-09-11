// import 'dart:ui';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../../core/router/app_router.dart';
// import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/adhan_scheduler_service.dart';
//
// import '../../../locations/domain/entity/current_location_entity.dart';
// import '../../../locations/domain/entity/location_entity.dart';
// import '../../../locations/presentation/pages/locationPage.dart';
// import 'home_event.dart';
// import 'home_state.dart';
//
// class HomeBloc extends Bloc<HomeEvent, HomeState> {
//   // ============================================================
//   // SharedPreferences Keys
//   // ============================================================
//
//   static const String locationModeKey = 'prayer_location_mode';
//
//   static const String locationModeAuto = 'auto';
//
//   static const String locationModeManual = 'manual';
//
//   static const String prayerCityNameKey = 'prayer_city_name';
//
//   static const String manualLatitudeKey =
//       'prayer_manual_latitude';
//
//   static const String manualLongitudeKey =
//       'prayer_manual_longitude';
//
//   static const String lastLatitudeKey =
//       'prayer_last_latitude';
//
//   static const String lastLongitudeKey =
//       'prayer_last_longitude';
//
//   // ============================================================
//   // Home Location Data
//   // ============================================================
//
//   double latitude;
//
//   double longitude;
//
//   String cityName;
//
//   bool locationReady = false;
//
//   bool adhanScheduled = false;
//
//   // ============================================================
//   // Constructor
//   // ============================================================
//
//   HomeBloc({
//     double initialLatitude = 30.0444,
//     double initialLongitude = 31.2357,
//     this.cityName = '',
//   })  : latitude = initialLatitude,
//         longitude = initialLongitude,
//         super(const HomeInitial()) {
//     // Load location when Home starts
//     on<LoadHomeLocation>(_loadLocationAndPrayerTimes);
//
//     // Location selected from LocationPage
//     on<HomeLocationSelected>(_reloadPrayerTimesAndAlarms);
//   }
//
//   // ============================================================
//   // 1. OPEN LOCATION PAGE
//   // ============================================================
//
//   Future<void> _openLocationPage(
//       BuildContext context,
//       ) async {
//     final result = await Navigator.pushNamed(
//       context,
//       AppRouter.locationPage,
//     );
//
//     if (result == null) {
//       return;
//     }
//
//     if (result is! Map) {
//       debugPrint(
//         '❌ INVALID LOCATION RESULT: '
//             '${result.runtimeType}',
//       );
//
//       return;
//     }
//
//     final location = result['location'];
//
//     final type = result['type'];
//
//     if (location == null || type == null) {
//       debugPrint(
//         '❌ LOCATION RESULT IS MISSING DATA',
//       );
//
//       return;
//     }
//
//     add(
//       HomeLocationSelected(
//         location: location,
//         type: type,
//       ),
//     );
//   }
//
//   // ============================================================
//   // 2. LOAD LOCATION AND PRAYER TIMES
//   // ============================================================
//
//   Future<void> _loadLocationAndPrayerTimes(
//       LoadHomeLocation event,
//       Emitter<HomeState> emit,
//       )
//   async {
//     try {
//       emit(
//         const HomeLocationLoading(),
//       );
//
//       final prefs =
//       await SharedPreferences.getInstance();
//
//       // --------------------------------------------------------
//       // Load saved city
//       // --------------------------------------------------------
//
//       final savedCity =
//       prefs.getString(
//         prayerCityNameKey,
//       );
//
//       if (savedCity != null &&
//           savedCity.trim().isNotEmpty) {
//         cityName = savedCity;
//       }
//
//       // --------------------------------------------------------
//       // Load location mode
//       // --------------------------------------------------------
//
//       final mode =
//           prefs.getString(
//             locationModeKey,
//           ) ??
//               locationModeAuto;
//
//       debugPrint(
//         '📍 HOME LOCATION | mode=$mode',
//       );
//
//       // ========================================================
//       // MANUAL LOCATION
//       // ========================================================
//
//       if (mode == locationModeManual) {
//         latitude =
//             prefs.getDouble(
//               manualLatitudeKey,
//             ) ??
//                 latitude;
//
//         longitude =
//             prefs.getDouble(
//               manualLongitudeKey,
//             ) ??
//                 longitude;
//
//         debugPrint(
//           '📍 HOME MANUAL LOCATION | '
//               'lat=$latitude | '
//               'lng=$longitude',
//         );
//       }
//
//       // ========================================================
//       // AUTOMATIC LOCATION
//       // ========================================================
//
//       else {
//         final currentLocation =
//         await _useAutomaticLocation();
//
//         latitude =
//             currentLocation.latitude;
//
//         longitude =
//             currentLocation.longitude;
//
//         cityName =
//             currentLocation.city;
//
//         debugPrint(
//           '📍 HOME GPS LOCATION | '
//               'city=$cityName | '
//               'lat=$latitude | '
//               'lng=$longitude',
//         );
//       }
//
//       // --------------------------------------------------------
//       // Location is ready
//       // --------------------------------------------------------
//
//       locationReady = true;
//
//       emit(
//         HomeLocationLoaded(
//           latitude: latitude,
//           longitude: longitude,
//           cityName: cityName,
//         ),
//       );
//
//     } catch (e, stackTrace) {
//       debugPrint(
//         '❌ LOAD HOME LOCATION FAILED: $e',
//       );
//
//       debugPrint(
//         '$stackTrace',
//       );
//
//       emit(
//         HomeLocationError(
//           e.toString(),
//         ),
//       );
//     }
//   }
//
//   // ============================================================
//   // 3. USE AUTOMATIC LOCATION
//   // ============================================================
//
//   Future<CurrentLocationEntity>
//   _useAutomaticLocation() async {
//     // ----------------------------------------------------------
//     // Check GPS service
//     // ----------------------------------------------------------
//
//     final serviceEnabled =
//     await Geolocator.isLocationServiceEnabled();
//
//     if (!serviceEnabled) {
//       throw Exception(
//         'يرجى تشغيل خدمة الموقع GPS',
//       );
//     }
//
//     // ----------------------------------------------------------
//     // Check permission
//     // ----------------------------------------------------------
//
//     var permission =
//     await Geolocator.checkPermission();
//
//     if (permission ==
//         LocationPermission.denied) {
//       permission =
//       await Geolocator.requestPermission();
//     }
//
//     if (permission ==
//         LocationPermission.denied ||
//         permission ==
//             LocationPermission.deniedForever) {
//       throw Exception(
//         'لم يتم السماح بالوصول إلى الموقع',
//       );
//     }
//
//     // ----------------------------------------------------------
//     // Get current GPS position
//     // ----------------------------------------------------------
//
//     final position =
//     await Geolocator.getCurrentPosition(
//       locationSettings:
//       const LocationSettings(
//         accuracy: LocationAccuracy.high,
//       ),
//     );
//
//     final lat =
//         position.latitude;
//
//     final lng =
//         position.longitude;
//
//     debugPrint(
//       '📍 GPS POSITION | '
//           'lat=$lat | '
//           'lng=$lng',
//     );
//
//     // ----------------------------------------------------------
//     // Reverse Geocoding
//     // ----------------------------------------------------------
//
//     final city =
//     await _getCityNameFromCoordinates(
//       lat,
//       lng,
//     );
//
//     debugPrint(
//       '🌍 REVERSE GEOCODING | '
//           'city=$city',
//     );
//
//     // ----------------------------------------------------------
//     // Save automatic location
//     // ----------------------------------------------------------
//
//     final prefs =
//     await SharedPreferences.getInstance();
//
//     await prefs.setString(
//       locationModeKey,
//       locationModeAuto,
//     );
//
//     await prefs.setString(
//       prayerCityNameKey,
//       city,
//     );
//
//     await prefs.setDouble(
//       lastLatitudeKey,
//       lat,
//     );
//
//     await prefs.setDouble(
//       lastLongitudeKey,
//       lng,
//     );
//
//     // ----------------------------------------------------------
//     // Return location entity
//     // ----------------------------------------------------------
//
//     return CurrentLocationEntity(
//       latitude: lat,
//       longitude: lng,
//       city: city,
//       country: '',
//     );
//   }
//
//   // ============================================================
//   // 4. RELOAD PRAYER TIMES AND ALARMS
//   // ============================================================
//
//   Future<void> _reloadPrayerTimesAndAlarms(
//       HomeLocationSelected event,
//       Emitter<HomeState> emit,
//       ) async {
//     try {
//       emit(
//         const HomeLocationLoading(),
//       );
//
//       final location =
//           event.location;
//
//       final type =
//           event.type;
//
//       double lat;
//
//       double lng;
//
//       String city;
//
//       // ========================================================
//       // CURRENT GPS LOCATION
//       // ========================================================
//
//       if (location is CurrentLocationEntity) {
//         lat =
//             location.latitude;
//
//         lng =
//             location.longitude;
//
//         city =
//             location.city;
//
//         debugPrint(
//           '📍 CURRENT GPS | '
//               'city=${location.city} | '
//               'country=${location.country} | '
//               'lat=$lat | '
//               'lng=$lng',
//         );
//       }
//
//       // ========================================================
//       // MANUAL LOCATION
//       // ========================================================
//
//       else if (location is LocationEntity) {
//         lat =
//             location.latitude;
//
//         lng =
//             location.longitude;
//
//         city =
//             location.city;
//
//         debugPrint(
//           '📍 MANUAL LOCATION | '
//               'city=${location.city} | '
//               'country=${location.country} | '
//               'lat=$lat | '
//               'lng=$lng',
//         );
//       }
//
//       // ========================================================
//       // INVALID LOCATION
//       // ========================================================
//
//       else {
//         throw Exception(
//           'Invalid location type: '
//               '${location.runtimeType}',
//         );
//       }
//
//       // --------------------------------------------------------
//       // Update Home values
//       // --------------------------------------------------------
//
//       latitude = lat;
//
//       longitude = lng;
//
//       cityName = city;
//
//       // --------------------------------------------------------
//       // Save location
//       // --------------------------------------------------------
//
//       final prefs =
//       await SharedPreferences.getInstance();
//
//       await prefs.setString(
//         prayerCityNameKey,
//         city,
//       );
//
//       // ========================================================
//       // CURRENT LOCATION = AUTO
//       // ========================================================
//
//       if (type ==
//           LocationSelectionType.current) {
//         await prefs.setString(
//           locationModeKey,
//           locationModeAuto,
//         );
//
//         debugPrint(
//           '📍 HOME LOCATION MODE = AUTO',
//         );
//       }
//
//       // ========================================================
//       // MANUAL LOCATION
//       // ========================================================
//
//       else {
//         await prefs.setString(
//           locationModeKey,
//           locationModeManual,
//         );
//
//         await prefs.setDouble(
//           manualLatitudeKey,
//           lat,
//         );
//
//         await prefs.setDouble(
//           manualLongitudeKey,
//           lng,
//         );
//
//         debugPrint(
//           '📍 HOME LOCATION MODE = MANUAL',
//         );
//       }
//
//       // --------------------------------------------------------
//       // Save last location
//       // --------------------------------------------------------
//
//       await prefs.setDouble(
//         lastLatitudeKey,
//         lat,
//       );
//
//       await prefs.setDouble(
//         lastLongitudeKey,
//         lng,
//       );
//
//       // --------------------------------------------------------
//       // Reset scheduling flag
//       // --------------------------------------------------------
//
//       locationReady = true;
//
//       adhanScheduled = false;
//
//       // ========================================================
//       // CANCEL OLD ADHAN ALARMS
//       // ========================================================
//
//       try {
//         await AdhanSchedulerService()
//             .cancelAdhans();
//
//         debugPrint(
//           '✅ OLD ADHAN ALARMS CANCELLED',
//         );
//       } catch (e, stackTrace) {
//         debugPrint(
//           '❌ CANCEL OLD ALARMS FAILED: $e',
//         );
//
//         debugPrint(
//           '$stackTrace',
//         );
//       }
//
//       // --------------------------------------------------------
//       // Log updated location
//       // --------------------------------------------------------
//
//       debugPrint(
//         '🏠 HOME LOCATION UPDATED | '
//             'lat=$latitude | '
//             'lng=$longitude | '
//             'city=$cityName',
//       );
//
//       // --------------------------------------------------------
//       // Notify HomePage
//       // --------------------------------------------------------
//
//       emit(
//         HomeLocationLoaded(
//           latitude: latitude,
//           longitude: longitude,
//           cityName: cityName,
//         ),
//       );
//
//     } catch (e, stackTrace) {
//       debugPrint(
//         '❌ LOCATION SELECTION FAILED: $e',
//       );
//
//       debugPrint(
//         '$stackTrace',
//       );
//
//       emit(
//         HomeLocationError(
//           e.toString(),
//         ),
//       );
//     }
//   }
//
//   // ============================================================
//   // 5. GET CITY NAME FROM COORDINATES
//   // ============================================================
//
//   Future<String>
//   _getCityNameFromCoordinates(
//       double latitude,
//       double longitude,
//       ) async {
//     try {
//       debugPrint(
//         '🌍 START REVERSE GEOCODING | '
//             'lat=$latitude | '
//             'lng=$longitude',
//       );
//
//       final placemarks =
//       await Geocoding()
//           .placemarkFromCoordinates(
//         latitude,
//         longitude,
//         locale:
//         const Locale(
//           'en',
//           'US',
//         ),
//       );
//
//       debugPrint(
//         '🌍 GEOCODING RESULTS COUNT = '
//             '${placemarks.length}',
//       );
//
//       if (placemarks.isEmpty) {
//         return 'Current Location';
//       }
//
//       // --------------------------------------------------------
//       // Print all results
//       // --------------------------------------------------------
//
//       for (final place in placemarks) {
//         debugPrint(
//           '📍 PLACE | '
//               'name=${place.name} | '
//               'locality=${place.locality} | '
//               'subLocality=${place.subLocality} | '
//               'subAdministrativeArea=${place.subAdministrativeArea} | '
//               'administrativeArea=${place.administrativeArea} | '
//               'country=${place.country}',
//         );
//       }
//
//       final place =
//           placemarks.first;
//
//       // --------------------------------------------------------
//       // Locality
//       // --------------------------------------------------------
//
//       final locality =
//       place.locality?.trim();
//
//       if (locality != null &&
//           locality.isNotEmpty) {
//         return locality;
//       }
//
//       // --------------------------------------------------------
//       // Sub Locality
//       // --------------------------------------------------------
//
//       final subLocality =
//       place.subLocality?.trim();
//
//       if (subLocality != null &&
//           subLocality.isNotEmpty) {
//         return subLocality;
//       }
//
//       // --------------------------------------------------------
//       // Sub Administrative Area
//       // --------------------------------------------------------
//
//       final subAdministrativeArea =
//       place.subAdministrativeArea
//           ?.trim();
//
//       if (subAdministrativeArea != null &&
//           subAdministrativeArea.isNotEmpty) {
//         return subAdministrativeArea;
//       }
//
//       // --------------------------------------------------------
//       // Administrative Area
//       // --------------------------------------------------------
//
//       final administrativeArea =
//       place.administrativeArea
//           ?.trim();
//
//       if (administrativeArea != null &&
//           administrativeArea.isNotEmpty) {
//         return administrativeArea;
//       }
//
//       return 'Current Location';
//
//     } catch (e, stackTrace) {
//       debugPrint(
//         '❌ REVERSE GEOCODING FAILED: $e',
//       );
//
//       debugPrint(
//         '$stackTrace',
//       );
//
//       return 'Current Location';
//     }
//   }
// }