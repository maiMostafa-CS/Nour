import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_qibla_direction.dart';
import 'bloc_event.dart';
import 'bloc_state.dart';


class QiblaBloc
    extends Bloc<QiblaEvent, QiblaState> {
  final GetQiblaDirection getQiblaDirection;

  QiblaBloc(
      this.getQiblaDirection,
      ) : super(const QiblaState()) {
    on<QiblaStarted>(_onQiblaStarted);
    on<QiblaRetry>(_onQiblaRetry);
  }

  Future<void> _onQiblaStarted(
      QiblaStarted event,
      Emitter<QiblaState> emit,
      ) async {
    await _getQibla(emit);
  }

  Future<void> _onQiblaRetry(
      QiblaRetry event,
      Emitter<QiblaState> emit,
      ) async {
    await _getQibla(emit);
  }

  Future<void> _getQibla(
      Emitter<QiblaState> emit,
      ) async {
    emit(
      state.copyWith(
        status: QiblaStatus.loading,
        clearError: true,
      ),
    );

    try {
      final qibla =
      await getQiblaDirection();

      emit(
        state.copyWith(
          status: QiblaStatus.loaded,
          qibla: qibla,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: QiblaStatus.error,
          errorMessage:
          e.toString().replaceFirst(
            'Exception: ',
            '',
          ),
        ),
      );
    }
  }
}