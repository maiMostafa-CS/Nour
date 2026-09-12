import 'package:equatable/equatable.dart';

import '../../domain/entities/iqama_settings_entity.dart';

enum IqamaSettingsStatus {
  initial,
  loading,
  loaded,
  updating,
  error,
}

class IqamaSettingsState extends Equatable {
  final IqamaSettingsStatus status;
  final IqamaSettingsEntity settings;
  final String? errorMessage;

  const IqamaSettingsState({
    this.status = IqamaSettingsStatus.initial,
    this.settings = const IqamaSettingsEntity(
      fajr: 15,
      sunrise: 15,
      dhuhr: 15,
      asr: 15,
      maghrib: 15,
      isha: 15,
    ),
    this.errorMessage,
  });

  IqamaSettingsState copyWith({
    IqamaSettingsStatus? status,
    IqamaSettingsEntity? settings,
    String? errorMessage,
    bool clearError = false,
  }) {
    return IqamaSettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage:
      clearError
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