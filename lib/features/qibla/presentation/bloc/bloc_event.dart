import 'package:equatable/equatable.dart';

abstract class QiblaEvent extends Equatable {
  const QiblaEvent();

  @override
  List<Object?> get props => [];
}

class QiblaStarted extends QiblaEvent {
  const QiblaStarted();
}

class QiblaRetry extends QiblaEvent {
  const QiblaRetry();
}