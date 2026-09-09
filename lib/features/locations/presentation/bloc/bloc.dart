import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/get_all_locations.dart';
import '../../domain/usecase/get_cities.dart';
import '../../domain/usecase/get_city_by_coordinates.dart';
import '../../domain/usecase/get_current_location.dart';

import 'blocEvent.dart';
import 'blocState.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetAllLocations getAllLocations;
  final GetCitiesByCountry getCitiesByCountry;
  final GetLocationByCity getLocationByCity;
  final GetCurrentLocationUseCase getCurrentLocation;

  LocationBloc({
    required this.getAllLocations,
    required this.getCitiesByCountry,
    required this.getLocationByCity,
    required this.getCurrentLocation,
  }) : super(const LocationState()) {
    // ============================================================
    // EVENTS
    // ============================================================

    on<LoadLocations>(
      _onLoadLocations,
    );

    on<LoadCitiesByCountry>(
      _onLoadCitiesByCountry,
    );

    on<FindLocationByCity>(
      _onFindLocationByCity,
    );

    on<GetCurrentLocation>(
      _onGetCurrentLocation,
    );
  }

  // ============================================================
  // LOAD ALL LOCATIONS
  // ============================================================

  Future<void> _onLoadLocations(
      LoadLocations event,
      Emitter<LocationState> emit,
      ) async {
    emit(
      state.copyWith(
        status: LocationStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final locations = await getAllLocations();

      emit(
        state.copyWith(
          status: LocationStatus.success,
          locations: locations,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // LOAD CITIES BY COUNTRY
  // ============================================================

  Future<void> _onLoadCitiesByCountry(
      LoadCitiesByCountry event,
      Emitter<LocationState> emit,
      ) async {
    emit(
      state.copyWith(
        status: LocationStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final locations = await getCitiesByCountry(
        event.countryCode,
      );

      emit(
        state.copyWith(
          status: LocationStatus.success,
          locations: locations,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // FIND CITY
  // ============================================================

  Future<void> _onFindLocationByCity(
      FindLocationByCity event,
      Emitter<LocationState> emit,
      ) async {
    emit(
      state.copyWith(
        status: LocationStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final location = await getLocationByCity(
        event.city,
      );

      if (location == null) {
        emit(
          state.copyWith(
            status: LocationStatus.failure,
            errorMessage: 'City not found',
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          status: LocationStatus.success,
          selectedLocation: location,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // GET CURRENT LOCATION
  // ============================================================

  Future<void> _onGetCurrentLocation(
      GetCurrentLocation event,
      Emitter<LocationState> emit,
      ) async {
    emit(
      state.copyWith(
        status: LocationStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final location = await getCurrentLocation();

      emit(
        state.copyWith(
          status: LocationStatus.success,
          currentLocation: location,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}