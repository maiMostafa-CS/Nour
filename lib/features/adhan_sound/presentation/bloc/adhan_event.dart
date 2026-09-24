import 'package:equatable/equatable.dart';

abstract class AdhanEvent extends Equatable {
  const AdhanEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// LOAD RECITERS (for this bloc's prayer)
// ============================================================

class LoadAdhanReciters extends AdhanEvent {
  const LoadAdhanReciters();
}

// ============================================================
// SELECT RECITER
// ============================================================

class SelectAdhanReciter extends AdhanEvent {
  final String reciterId;

  const SelectAdhanReciter({required this.reciterId});

  @override
  List<Object?> get props => [reciterId];
}