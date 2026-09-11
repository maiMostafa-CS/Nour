import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/config/prayer_scheduler_config.dart';
import '../../domain/entity/current_location_entity.dart';
import '../../domain/entity/location_entity.dart';
import '../bloc/bloc.dart';
import '../bloc/blocEvent.dart';
import '../bloc/blocState.dart';
import '../widgets/ErrorView.dart';
import '../widgets/coordinateRow.dart';
import '../widgets/current_location_dialog.dart';
import 'countrySelectionScreen.dart';

enum LocationSelectionType {
  current,
  manual,
}

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final TextEditingController _searchController =
  TextEditingController();

  String? _selectedCountryCode;
  String? _selectedCountryName;

  @override
  void initState() {
    super.initState();

    context.read<LocationBloc>().add(
      const LoadLocations(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Location',
          style: TextStyle(
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<LocationBloc, LocationState>(
        listener:
            (context, state) async {
          if (state.status == LocationStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage!,
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
              ),
            );
          }

          if (state.status == LocationStatus.success &&
              state.currentLocation != null) {
            final location = state.currentLocation!;

            debugPrint(
              '📍 CURRENT LOCATION RESULT | '
                  'lat=${location.latitude} | '
                  'lng=${location.longitude}',
            );

            await _saveCurrentLocation(
              context,
              location,
            );
          }
        },
        builder: (context, state) {
          if (state.status == LocationStatus.loading &&
              state.locations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == LocationStatus.failure &&
              state.locations.isEmpty) {
            return ErrorView(
              message:
              state.errorMessage ?? 'Something went wrong',
              onRetry: () {
                context.read<LocationBloc>().add(
                  const LoadLocations(),
                );
              },
            );
          }

          if (state.locations.isEmpty) {
            return Center(
              child: Text(
                'No locations found',
                style: TextStyle(
                  fontSize: 14.sp,
                ),
              ),
            );
          }

          return _buildLocationChoiceScreen(
            context,
            state,
          );
        },
      ),
    );
  }

  // ============================================================
  // SCREEN 1
  // LOCATION CHOICE
  // ============================================================

  Widget _buildLocationChoiceScreen(
      BuildContext context,
      LocationState state,
      ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 16.h),

          Text(
            'Choose your location',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            'Select how you want to set your prayer location',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),

          SizedBox(height: 32.h),

          // ======================================================
          // CURRENT LOCATION CARD
          // ======================================================

          _buildCurrentLocationCard(
            context,
            state,
          ),

          SizedBox(height: 16.h),

          // ======================================================
          // MANUAL LOCATION CARD
          // ======================================================

          _buildManualLocationCard(
            context,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CURRENT LOCATION CARD
  // ============================================================

  Widget _buildCurrentLocationCard(
      BuildContext context,
      LocationState state,
      ) {
    final isLoading =
        state.status == LocationStatus.loading;

    final primaryColor =
        Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading
            ? null
            : () async {
          final shouldUpdate =
          await showCurrentLocationDialog(context);

          if (!shouldUpdate) return;

          final ready =
          await CurrentLocationHelper
              .checkAndRequestPermission(context);

          if (!ready) return;

          if (!context.mounted) return;

          context.read<LocationBloc>().add(
            const GetCurrentLocation(),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              // ICON
              Container(
                width: 58.w,
                height: 58.h,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.my_location,
                  size: 28.sp,
                  color: primaryColor,
                ),
              ),

              SizedBox(width: 16.w),

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use Current Location',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 6.h),

                    Text(
                      'Automatically detect your location using GPS',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    if (state.currentLocation != null) ...[
                      SizedBox(height: 6.h),

                      Text(
                        '${state.currentLocation!.city}, '
                            '${state.currentLocation!.country}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 3.h),

                      Text(
                        '${state.currentLocation!.latitude.toStringAsFixed(4)}, '
                            '${state.currentLocation!.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              if (isLoading)
                SizedBox(
                  width: 22.w,
                  height: 22.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 17.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MANUAL LOCATION CARD
  // ============================================================

  Widget _buildManualLocationCard(
      BuildContext context,
      ) {
    final primaryColor =
        Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CountrySelectionScreen(
                    locations: context
                        .read<LocationBloc>()
                        .state
                        .locations,
                    onCountrySelected: (
                        countryCode,
                        countryName,
                        ) {
                      _selectedCountryCode = countryCode;
                      _selectedCountryName = countryName;
                    },
                    onCitySelected: (location) {
                      context.read<LocationBloc>().add(
                        FindLocationByCity(
                          location.city,
                        ),
                      );

                      _showLocationConfirmation(
                        context,
                        location,
                      );
                    },
                  ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              // ICON
              Container(
                width: 58.w,
                height: 58.h,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.public,
                  size: 28.sp,
                  color: primaryColor,
                ),
              ),

              SizedBox(width: 16.w),

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Location Manually',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 6.h),

                    Text(
                      'Choose your country and city manually',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              Icon(
                Icons.arrow_forward_ios,
                size: 17.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOCATION CONFIRMATION
  // ============================================================

  void _showLocationConfirmation(
      BuildContext context,
      dynamic location,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius:
                    BorderRadius.circular(10.r),
                  ),
                ),

                SizedBox(height: 24.h),

                Icon(
                  Icons.location_on,
                  size: 50.sp,
                ),

                SizedBox(height: 16.h),

                Text(
                  location.city,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  location.country,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: 20.h),

                CoordinateRow(
                  label: 'Latitude',
                  value: location.latitude.toString(),
                ),

                CoordinateRow(
                  label: 'Longitude',
                  value: location.longitude.toString(),
                ),

                SizedBox(height: 24.h),

                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      await _saveLocation(
                        this.context,
                        location,
                      );
                    },
                    child: Text(
                      'Use this location',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SAVE LOCATION
  // ============================================================

  Future<void> _saveLocation(
      BuildContext context,
      LocationEntity location,
      )
  async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'prayer_location_mode',
      'manual',
    );

    await prefs.setDouble(
      'prayer_manual_latitude',
      location.latitude,
    );

    await prefs.setDouble(
      'prayer_manual_longitude',
      location.longitude,
    );

    await prefs.setString(
      'prayer_city_name',
      location.city,
    );

    await prefs.setString(
      'prayer_country_name',
      location.country,
    );

    await prefs.setDouble(
      prayerLastLatitudePrefsKey,
      location.latitude,
    );

    await prefs.setDouble(
      prayerLastLongitudePrefsKey,
      location.longitude,
    );

    debugPrint(
      '📍 LOCATION SAVED | '
          'city=${location.city} | '
          'country=${location.country} | '
          'lat=${location.latitude} | '
          'lng=${location.longitude}',
    );

    if (!context.mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
          (route) => false,
    );
  }
  Future<void> _saveCurrentLocation(
      BuildContext context,
      CurrentLocationEntity location,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('prayer_location_mode', 'auto');

    await prefs.setDouble(
      'prayer_current_latitude',
      location.latitude,
    );

    await prefs.setDouble(
      'prayer_current_longitude',
      location.longitude,
    );

    await prefs.setString(
      'prayer_city_name',
      location.city,
    );

    await prefs.setString(
      'prayer_country_name',
      location.country,
    );

    await prefs.setDouble(
      prayerLastLatitudePrefsKey,
      location.latitude,
    );

    await prefs.setDouble(
      prayerLastLongitudePrefsKey,
      location.longitude,
    );

    debugPrint(
      '📍 CURRENT LOCATION SAVED | '
          'city=${location.city} | '
          'country=${location.country} | '
          'lat=${location.latitude} | '
          'lng=${location.longitude}',
    );

    if (!context.mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
          (route) => false,
    );
  }
  // Future<void> showCurrentLocationDialog(
  //     BuildContext context,
  //     )
  // async {
  //   final result = await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) {
  //       return AlertDialog(
  //         icon: Icon(
  //           Icons.location_on,
  //           size: 42.sp,
  //           color: Theme.of(context).colorScheme.primary,
  //         ),
  //         title: Text(
  //           'Update Current Location',
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //             fontSize: 20.sp,
  //           ),
  //         ),
  //         content: Text(
  //           'Your current location will be updated.\n\n'
  //               'Please make sure that Location/GPS is enabled '
  //               'on your device.\n\n'
  //               'If Location is disabled, please enable it '
  //               'before continuing.',
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //             fontSize: 14.sp,
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(
  //                 dialogContext,
  //                 false,
  //               );
  //             },
  //             child: Text(
  //               'Cancel',
  //               style: TextStyle(
  //                 fontSize: 14.sp,
  //               ),
  //             ),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(
  //                 dialogContext,
  //                 true,
  //               );
  //             },
  //             child: Text(
  //               'Update Location',
  //               style: TextStyle(
  //                 fontSize: 14.sp,
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //
  //   if (result != true) {
  //     return;
  //   }
  //
  //   await _updateCurrentLocation(
  //     context,
  //   );
  // }
  // Future<void> _updateCurrentLocation(
  //     BuildContext context,
  //     )
  // async {
  //   try {
  //     final serviceEnabled =
  //     await Geolocator.isLocationServiceEnabled();
  //
  //     debugPrint(
  //       '📍 GPS SERVICE ENABLED = $serviceEnabled',
  //     );
  //
  //     if (!serviceEnabled) {
  //       if (!context.mounted) return;
  //
  //       await _showLocationServiceDialog(context);
  //       return;
  //     }
  //
  //     LocationPermission permission =
  //     await Geolocator.checkPermission();
  //
  //     debugPrint(
  //       '📍 LOCATION PERMISSION BEFORE = $permission',
  //     );
  //
  //     if (permission == LocationPermission.denied) {
  //       permission =
  //       await Geolocator.requestPermission();
  //
  //       debugPrint(
  //         '📍 LOCATION PERMISSION AFTER = $permission',
  //       );
  //     }
  //
  //     if (permission == LocationPermission.denied) {
  //       if (!context.mounted) return;
  //
  //       _showMessage(
  //         context,
  //         'Location permission is required.',
  //       );
  //
  //       return;
  //     }
  //
  //     if (permission ==
  //         LocationPermission.deniedForever) {
  //       if (!context.mounted) return;
  //
  //       await _showPermissionSettingsDialog(context);
  //       return;
  //     }
  //
  //     // ============================================================
  //     // EVERYTHING IS OK
  //     // ============================================================
  //
  //     debugPrint(
  //       '📍 LOCATION READY → REQUESTING BLOC',
  //     );
  //
  //     if (!context.mounted) return;
  //
  //     context.read<LocationBloc>().add(
  //       const GetCurrentLocation(),
  //     );
  //   } catch (e, stackTrace) {
  //     debugPrint(
  //       '❌ CURRENT LOCATION REQUEST FAILED',
  //     );
  //
  //     debugPrint(
  //       '❌ ERROR = $e',
  //     );
  //
  //     debugPrint(
  //       '❌ STACK = $stackTrace',
  //     );
  //
  //     if (!context.mounted) return;
  //
  //     _showMessage(
  //       context,
  //       'Unable to get your current location.',
  //     );
  //   }
  // }
  // Future<void> _showLocationServiceDialog(
  //     BuildContext context,
  //     )
  // async {
  //   final openSettings = await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) {
  //       return AlertDialog(
  //         icon: Icon(
  //           Icons.location_off,
  //           size: 42.sp,
  //         ),
  //         title: Text(
  //           'Location is disabled',
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //             fontSize: 20.sp,
  //           ),
  //         ),
  //         content: Text(
  //           'Your device location is currently disabled.\n\n'
  //               'Please open Location Settings and enable '
  //               'Location/GPS, then try again.',
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //             fontSize: 14.sp,
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(
  //                 dialogContext,
  //                 false,
  //               );
  //             },
  //             child: Text(
  //               'Cancel',
  //               style: TextStyle(
  //                 fontSize: 14.sp,
  //               ),
  //             ),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(
  //                 dialogContext,
  //                 true,
  //               );
  //             },
  //             child: Text(
  //               'Open Settings',
  //               style: TextStyle(
  //                 fontSize: 14.sp,
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //
  //   if (openSettings == true) {
  //     await Geolocator.openLocationSettings();
  //   }
  // }
  //
  // Future<void> _showPermissionSettingsDialog(
  //     BuildContext context,
  //     )
  // async {
  //   final openSettings = await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) {
  //       return AlertDialog(
  //         icon: Icon(
  //           Icons.location_disabled,
  //           size: 42.sp,
  //         ),
  //         title: Text(
  //           'Location Permission Required',
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //             fontSize: 20.sp,
  //           ),
  //         ),
  //         content: Text(
  //           'Location permission has been denied.\n\n'
  //               'Please open the app settings and allow '
  //               'location permission to continue.',
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //             fontSize: 14.sp,
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(
  //                 dialogContext,
  //                 false,
  //               );
  //             },
  //             child: Text(
  //               'Cancel',
  //               style: TextStyle(
  //                 fontSize: 14.sp,
  //               ),
  //             ),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(
  //                 dialogContext,
  //                 true,
  //               );
  //             },
  //             child: Text(
  //               'Open Settings',
  //               style: TextStyle(
  //                 fontSize: 14.sp,
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //
  //   if (openSettings == true) {
  //     await Geolocator.openAppSettings();
  //   }
  // }
  //
  // void _showMessage(
  //     BuildContext context,
  //     String message,
  //     ) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         message,
  //         style: TextStyle(
  //           fontSize: 14.sp,
  //         ),
  //       ),
  //     ),
  //   );
  // }
}