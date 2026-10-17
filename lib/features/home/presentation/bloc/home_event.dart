import 'package:equatable/equatable.dart';

import '../../../locations/domain/entity/current_location_entity.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHome extends HomeEvent {
  const LoadHome();
}

class HomeLocationChanged extends HomeEvent {
  final CurrentLocationEntity location;
  final bool isAutoDetected;

  const HomeLocationChanged(this.location, {this.isAutoDetected = false});

  @override
  List<Object?> get props => [location, isAutoDetected];
}

class RefreshLocation extends HomeEvent {
  const RefreshLocation();
}

class CheckLocationIfChanged extends HomeEvent {
  const CheckLocationIfChanged();
}

class ClearAutoUpdateMessage extends HomeEvent {
  const ClearAutoUpdateMessage();
}