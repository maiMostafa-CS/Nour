import 'package:equatable/equatable.dart';

abstract class AdhanEvent extends Equatable {
  const AdhanEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdhanReciters extends AdhanEvent {
  const LoadAdhanReciters();
}

class SelectAdhanReciter extends AdhanEvent {
  final String reciterId;

  const SelectAdhanReciter(
      this.reciterId,
      );

  @override
  List<Object?> get props => [
    reciterId,
  ];
}