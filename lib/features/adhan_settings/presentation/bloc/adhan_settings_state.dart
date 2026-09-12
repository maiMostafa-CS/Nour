import 'package:equatable/equatable.dart';

import '../../domain/entities/adhan_settings_entity.dart';

enum AdhanSettingsStatus {
  initial,
  loading,
  loaded,
  updating,
  error,
}

class AdhanSettingsState extends Equatable {
  final AdhanSettingsStatus status;
  final AdhanSettingsEntity settings;
  final String? errorMessage;

  const AdhanSettingsState({
    this.status = AdhanSettingsStatus.initial,
    this.settings = const AdhanSettingsEntity(
      fajr: true,
      sunrise: false,
      dhuhr: true,
      asr: true,
      maghrib: true,
      isha: true,
    ),
    this.errorMessage,
  });

  AdhanSettingsState copyWith({
    AdhanSettingsStatus? status,
    AdhanSettingsEntity? settings,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdhanSettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    settings,
    errorMessage,
  ];
}