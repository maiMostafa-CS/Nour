part of 'adhkar_bloc.dart';

sealed class AdhkarState extends Equatable {
  const AdhkarState();
}

class AdhkarInitial extends AdhkarState {
  const AdhkarInitial();
  @override List<Object?> get props => [];
}

class AdhkarLoading extends AdhkarState {
  const AdhkarLoading();
  @override List<Object?> get props => [];
}

class AdhkarLoaded extends AdhkarState {
  final List<DhikrEntity> items;
  const AdhkarLoaded(this.items);
  @override List<Object?> get props => [items];
}

class AdhkarError extends AdhkarState {
  final String message;
  const AdhkarError(this.message);
  @override List<Object?> get props => [message];
}
