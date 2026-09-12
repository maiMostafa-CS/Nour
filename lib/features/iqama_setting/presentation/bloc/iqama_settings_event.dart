import 'package:equatable/equatable.dart';

abstract class IqamaSettingsEvent extends Equatable {
  const IqamaSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadIqamaSettings extends IqamaSettingsEvent {
  const LoadIqamaSettings();
}

class UpdateIqamaSettingEvent extends IqamaSettingsEvent {
  final int prayerIndex;
  final int minutes;

  const UpdateIqamaSettingEvent({
    required this.prayerIndex,
    required this.minutes,
  });

  @override
  List<Object?> get props => [
    prayerIndex,
    minutes,
  ];
}