import 'package:equatable/equatable.dart';

import '../../domain/entities/adhan_reciter_entity.dart';

abstract class AdhanState extends Equatable {
  const AdhanState();

  @override
  List<Object?> get props => [];
}

class AdhanInitial extends AdhanState {
  const AdhanInitial();
}

class AdhanLoading extends AdhanState {
  const AdhanLoading();
}

class AdhanLoaded extends AdhanState {
  final List<AdhanReciterEntity> reciters;
  final String selectedReciterId;

  const AdhanLoaded({
    required this.reciters,
    required this.selectedReciterId,
  });

  @override
  List<Object?> get props => [
    reciters,
    selectedReciterId,
  ];
}

class AdhanError extends AdhanState {
  final String message;

  const AdhanError(this.message);

  @override
  List<Object?> get props => [
    message,
  ];
}