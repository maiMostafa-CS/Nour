import 'package:equatable/equatable.dart';

abstract class AdhanSettingsEvent extends Equatable {
  const AdhanSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdhanSettings extends AdhanSettingsEvent {
  const LoadAdhanSettings();
}

class ToggleAdhanSetting extends AdhanSettingsEvent {
  final int prayerIndex;
  final bool enabled;

  const ToggleAdhanSetting({
    required this.prayerIndex,
    required this.enabled,
  });

  @override
  List<Object?> get props => [
    prayerIndex,
    enabled,
  ];
}