// lib/features/tasbih/bloc/tasbih_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/tasbih_data.dart';
import '../../models/tasbih_model.dart';
import '../widgets/custom_dhikr_storage.dart';
import 'tasbih_event.dart';
import 'tasbih_state.dart';

class TasbihBloc extends Bloc<TasbihEvent, TasbihState> {
  final CustomDhikrStorage _storage;

  TasbihBloc({CustomDhikrStorage? storage})
      : _storage = storage ?? CustomDhikrStorage(),
        super(const TasbihState()) {
    on<TasbihLoadRequested>(_onLoad);
    on<TasbihIncremented>(_onIncrement);
    on<TasbihReset>(_onReset);
    on<TasbihResetAll>(_onResetAll);
    on<TasbihNextDhikr>(_onNext);
    on<TasbihPreviousDhikr>(_onPrevious);
    on<TasbihDhikrSelected>(_onSelect);
    on<TasbihRoundCompletedConsumed>(_onRoundConsumed);
    on<TasbihCustomDhikrAdded>(_onCustomAdded);
    on<TasbihCustomDhikrDeleted>(_onCustomDeleted);
    on<TasbihTargetCountChanged>(_onTargetCountChanged); // ✨
  }

  Future<void> _onLoad(
      TasbihLoadRequested event,
      Emitter<TasbihState> emit,
      ) async {
    emit(state.copyWith(status: TasbihStatus.loading));
    final custom = await _storage.loadCustomAdhkar();

    final all = [...TasbihData.defaultAdhkar, ...custom];

    emit(state.copyWith(status: TasbihStatus.loaded, adhkar: all));
  }

  void _onIncrement(TasbihIncremented event, Emitter<TasbihState> emit) {
    if (state.isCompleted) return;
    final newCount = state.currentCount + 1;
    final completed = newCount >= state.targetCount;
    emit(state.copyWith(
      currentCount: newCount,
      totalCount: state.totalCount + 1,
      completedRounds:
      completed ? state.completedRounds + 1 : state.completedRounds,
      justCompletedRound: completed,
    ));
  }

  void _onReset(TasbihReset event, Emitter<TasbihState> emit) {
    emit(state.copyWith(currentCount: 0, justCompletedRound: false));
  }

  void _onResetAll(TasbihResetAll event, Emitter<TasbihState> emit) {
    emit(state.copyWith(
      currentCount: 0,
      completedRounds: 0,
      totalCount: 0,
      justCompletedRound: false,
    ));
  }

  void _onNext(TasbihNextDhikr event, Emitter<TasbihState> emit) {
    if (state.adhkar.isEmpty) return;
    final next = (state.currentDhikrIndex + 1) % state.adhkar.length;
    emit(state.copyWith(currentDhikrIndex: next, currentCount: 0));
  }

  void _onPrevious(TasbihPreviousDhikr event, Emitter<TasbihState> emit) {
    if (state.adhkar.isEmpty) return;
    final prev =
        (state.currentDhikrIndex - 1 + state.adhkar.length) % state.adhkar.length;
    emit(state.copyWith(currentDhikrIndex: prev, currentCount: 0));
  }

  void _onSelect(TasbihDhikrSelected event, Emitter<TasbihState> emit) {
    if (event.index < 0 || event.index >= state.adhkar.length) return;
    emit(state.copyWith(currentDhikrIndex: event.index, currentCount: 0));
  }

  void _onRoundConsumed(
      TasbihRoundCompletedConsumed event,
      Emitter<TasbihState> emit,
      ) {
    emit(state.copyWith(justCompletedRound: false));
  }

  Future<void> _onCustomAdded(
      TasbihCustomDhikrAdded event,
      Emitter<TasbihState> emit,
      ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;

    final maxId = state.adhkar.isEmpty
        ? 0
        : state.adhkar.map((d) => d.id).reduce((a, b) => a > b ? a : b);

    final virtue = event.virtue?.trim();
    final newDhikr = TasbihDhikr(
      id: maxId + 1,
      text: text,
      virtue: (virtue == null || virtue.isEmpty) ? null : virtue,
      isCustom: true,
      targetCount: event.targetCount,
    );

    final updated = [...state.adhkar, newDhikr];
    await _storage.saveCustomAdhkar(updated);
    emit(state.copyWith(adhkar: updated));
  }

  Future<void> _onCustomDeleted(
      TasbihCustomDhikrDeleted event,
      Emitter<TasbihState> emit,
      ) async {
    final target = state.adhkar.firstWhere(
          (d) => d.id == event.dhikrId,
      orElse: () => const TasbihDhikr(id: -1, text: ''),
    );
    if (!target.isCustom) return;

    final updated =
    state.adhkar.where((d) => d.id != event.dhikrId).toList();
    await _storage.saveCustomAdhkar(updated);

    var newIndex = state.currentDhikrIndex;
    if (newIndex >= updated.length) newIndex = updated.length - 1;
    if (newIndex < 0) newIndex = 0;

    emit(state.copyWith(
      adhkar: updated,
      currentDhikrIndex: newIndex,
      currentCount: 0,
    ));
  }


  Future<void> _onTargetCountChanged(
      TasbihTargetCountChanged event,
      Emitter<TasbihState> emit,
      ) async {
    if (event.newTarget <= 0) return;
    if (state.adhkar.isEmpty) return;

    final updatedAdhkar = [...state.adhkar];
    final current = updatedAdhkar[state.currentDhikrIndex];

    updatedAdhkar[state.currentDhikrIndex] =
        current.copyWith(targetCount: event.newTarget);

    // حفظ التعديلات
    if (current.isCustom) {
      await _storage.saveCustomAdhkar(updatedAdhkar);
    } else {
      await _storage.saveModifiedDefaults(updatedAdhkar);
    }

    // إذا العدد الجديد أقل من الحالي → نضبط الحالي
    final newCurrentCount = state.currentCount > event.newTarget
        ? event.newTarget
        : state.currentCount;

    emit(state.copyWith(
      adhkar: updatedAdhkar,
      currentCount: newCurrentCount,
    ));
  }
}