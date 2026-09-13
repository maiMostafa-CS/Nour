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

  const HomeLocationChanged(this.location);

  @override
  List<Object?> get props => [location];
}
