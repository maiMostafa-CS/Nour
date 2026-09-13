import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/bloc.dart';
import '../bloc/blocEvent.dart';
import '../bloc/blocState.dart';
import '../widgets/ErrorView.dart';
import '../widgets/build_location_choice_screen.dart';
import '../widgets/savelocation.dart';

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
          'اختر الموقع',
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

            await saveLocation(
              context,
              latitude: location.latitude,
              longitude: location.longitude,
              city: location.city,
              country: location.country,
              timezone: location.timezone,
              isCurrentLocation: true,
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
              state.errorMessage ?? 'حدث خطأ ما',
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
                'لم يتم العثور على مواقع',
                style: TextStyle(
                  fontSize: 14.sp,
                ),
              ),
            );
          }

          return BuildLocationChoiceScreen(
            state: state,
          );
        },
      ),
    );
  }
}