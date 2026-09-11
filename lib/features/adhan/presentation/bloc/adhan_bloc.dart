import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/adhan_reciter_entity.dart';
import '../../domain/usecases/get_adhans.dart';
import '../../domain/usecases/get_selected_adhan.dart';
import '../../domain/usecases/save_selected_adhan.dart';

import 'adhan_event.dart';
import 'adhan_state.dart';

class AdhanBloc extends Bloc<AdhanEvent, AdhanState> {
  final GetAdhans getAdhans;
  final GetSelectedAdhan getSelectedAdhan;
  final SaveSelectedAdhan saveSelectedAdhan;

  AdhanBloc({
    required this.getAdhans,
    required this.getSelectedAdhan,
    required this.saveSelectedAdhan,
  }) : super(const AdhanInitial()) {
    on<LoadAdhanReciters>(_onLoadReciters);
    on<SelectAdhanReciter>(_onSelectReciter);
  }

  Future<void> _onLoadReciters(
      LoadAdhanReciters event,
      Emitter<AdhanState> emit,
      ) async {
    emit(const AdhanLoading());

    try {
      final reciters = await getAdhans();

      final savedId = await getSelectedAdhan();

      final selectedId =
          savedId ??
              (reciters.isNotEmpty
                  ? reciters.first.id
                  : '');

      emit(
        AdhanLoaded(
          reciters: reciters,
          selectedReciterId: selectedId,
        ),
      );
    } catch (e) {
      emit(
        AdhanError(
          e.toString(),
        ),
      );
    }
  }

  Future<void> _onSelectReciter(
      SelectAdhanReciter event,
      Emitter<AdhanState> emit,
      ) async {
    final currentState = state;

    if (currentState is! AdhanLoaded) {
      return;
    }

    await saveSelectedAdhan(
      event.reciterId,
    );

    emit(
      AdhanLoaded(
        reciters: currentState.reciters,
        selectedReciterId: event.reciterId,
      ),
    );
  }
}