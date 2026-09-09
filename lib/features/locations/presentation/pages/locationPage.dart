import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/config/prayer_scheduler_config.dart';
import '../../domain/entity/location_entity.dart';
import '../bloc/bloc.dart';
import '../bloc/blocEvent.dart';
import '../bloc/blocState.dart';
import '../widgets/ErrorView.dart';
import '../widgets/coordinateRow.dart';
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
        title: const Text(
          'Select Location',
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state.status == LocationStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage!,
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
            Navigator.of(context).pop({
              'type': LocationSelectionType.current,
              'location': location,
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Current location detected successfully',
                ),
              ),
            );

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
                  (route) => false,
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
            return const Center(
              child: Text(
                'No locations found',
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

  Widget _buildLocationChoiceScreen(BuildContext context,
      LocationState state,) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),

          const Text(
            'Choose your location',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Select how you want to set your prayer location',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 32),

// ======================================================
// CURRENT LOCATION CARD
// ======================================================

          _buildCurrentLocationCard(
            context,
            state,
          ),

          const SizedBox(height: 16),

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

  Widget _buildCurrentLocationCard(BuildContext context,
      LocationState state,) {
    final isLoading =
        state.status == LocationStatus.loading;

    final primaryColor =
        Theme
            .of(context)
            .colorScheme
            .primary;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
          showCurrentLocationDialog(
            context,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
// ICON
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.my_location,
                  size: 28,
                  color: primaryColor,
                ),
              ),

              const SizedBox(width: 16),

// TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Use Current Location',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Automatically detect your location using GPS',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    if (state.currentLocation != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${state.currentLocation!.city}, '
                            '${state.currentLocation!.country}',
                        style: TextStyle(
                          fontSize: 13,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        '${state.currentLocation!.latitude.toStringAsFixed(4)}, '
                            '${state.currentLocation!.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              if (isLoading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              else
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 17,
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

  Widget _buildManualLocationCard(BuildContext context,) {
    final primaryColor =
        Theme
            .of(context)
            .colorScheme
            .primary;

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
                    onCountrySelected: (countryCode,
                        countryName,) {
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
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
// ICON
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.public,
                  size: 28,
                  color: primaryColor,
                ),
              ),

              const SizedBox(width: 16),

// TEXT
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Location Manually',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Choose your country and city manually',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios,
                size: 17,
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

  void _showLocationConfirmation(BuildContext context,
      dynamic location,) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 24),

                const Icon(
                  Icons.location_on,
                  size: 50,
                ),

                const SizedBox(height: 16),

                Text(
                  location.city,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  location.country,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 20),

                CoordinateRow(
                  label: 'Latitude',
                  value: location.latitude.toString(),
                ),

                CoordinateRow(
                  label: 'Longitude',
                  value: location.longitude.toString(),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: ()  async {
                      Navigator.pop(context);

                      await _saveLocation(this.context, location);

                    },
                    child: const Text(
                      'Use this location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
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
      ) async {
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
  Future<void> showCurrentLocationDialog(
      BuildContext context,
      ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            Icons.location_on,
            size: 42,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text(
            'Update Current Location',
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Your current location will be updated.\n\n'
                'Please make sure that Location/GPS is enabled '
                'on your device.\n\n'
                'If Location is disabled, please enable it '
                'before continuing.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Update Location',
              ),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    await _updateCurrentLocation(
      context,
    );
  }
  Future<void> _updateCurrentLocation(
      BuildContext context,
      ) async {
    final serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!context.mounted) return;

      await _showLocationServiceDialog(
        context,
      );

      return;
    }

    final permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      final newPermission =
      await Geolocator.requestPermission();

      if (newPermission == LocationPermission.denied) {
        if (!context.mounted) return;

        _showMessage(
          context,
          'Location permission is required.',
        );

        return;
      }

      if (newPermission ==
          LocationPermission.deniedForever) {
        if (!context.mounted) return;

        await _showPermissionSettingsDialog(
          context,
        );

        return;
      }
    }

    if (permission ==
        LocationPermission.deniedForever) {
      if (!context.mounted) return;

      await _showPermissionSettingsDialog(
        context,
      );

      return;
    }

    // ============================================================
    // EVERYTHING IS OK
    // ============================================================

    if (!context.mounted) return;

    context.read<LocationBloc>().add(
      const GetCurrentLocation(),
    );
  }
  Future<void> _showLocationServiceDialog(
      BuildContext context,
      ) async {
    final openSettings = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.location_off,
            size: 42,
          ),
          title: const Text(
            'Location is disabled',
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Your device location is currently disabled.\n\n'
                'Please open Location Settings and enable '
                'Location/GPS, then try again.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Open Settings',
              ),
            ),
          ],
        );
      },
    );

    if (openSettings == true) {
      await Geolocator.openLocationSettings();
    }
  }
  Future<void> _showPermissionSettingsDialog(
      BuildContext context,
      ) async {
    final openSettings = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.location_disabled,
            size: 42,
          ),
          title: const Text(
            'Location Permission Required',
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Location permission has been denied.\n\n'
                'Please open the app settings and allow '
                'location permission to continue.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Open Settings',
              ),
            ),
          ],
        );
      },
    );

    if (openSettings == true) {
      await Geolocator.openAppSettings();
    }
  }
  void _showMessage(
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

