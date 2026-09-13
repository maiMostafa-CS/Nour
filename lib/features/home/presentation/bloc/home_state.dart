import 'package:equatable/equatable.dart';

import '../../../prayer_times/domain/entities/prayer_times_entity.dart';

class HomeState extends Equatable {
  final bool loading;
  final bool scheduling;
  final double latitude;
  final double longitude;
  final String cityName;
  final String timezone;
  final PrayerTimesEntity? prayerTimes;
  final String? errorMessage;

  const HomeState({
    this.loading = true,
    this.scheduling = false,
    this.latitude = 30.0444,
    this.longitude = 31.2357,
    this.cityName = 'Select location',
    this.timezone = 'Africa/Cairo',
    this.prayerTimes,
    this.errorMessage,
  });

  HomeState copyWith({
    bool? loading,
    bool? scheduling,
    double? latitude,
    double? longitude,
    String? cityName,
    String? timezone,
    PrayerTimesEntity? prayerTimes,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      loading: loading ?? this.loading,
      scheduling: scheduling ?? this.scheduling,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      timezone: timezone ?? this.timezone,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        loading,
        scheduling,
        latitude,
        longitude,
        cityName,
        timezone,
        prayerTimes,
        errorMessage,
      ];
}
