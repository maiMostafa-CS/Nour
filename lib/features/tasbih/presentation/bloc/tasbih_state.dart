// lib/features/tasbih/bloc/tasbih_state.dart

import 'package:equatable/equatable.dart';

import '../../models/tasbih_model.dart';

enum TasbihStatus { initial, loading, loaded }

class TasbihState extends Equatable {
  final TasbihStatus status;
  final List<TasbihDhikr> adhkar;
  final int currentDhikrIndex;
  final int currentCount;
  final int completedRounds;
  final int totalCount;
  final bool justCompletedRound;

  const TasbihState({
    this.status = TasbihStatus.initial,
    this.adhkar = const [],
    this.currentDhikrIndex = 0,
    this.currentCount = 0,
    this.completedRounds = 0,
    this.totalCount = 0,
    this.justCompletedRound = false,
  });

  // ✨ الآن targetCount يأتي من الذكر الحالي نفسه
  int get targetCount {
    if (adhkar.isEmpty) return 100;
    return adhkar[currentDhikrIndex].targetCount;
  }

  double get progress =>
      targetCount == 0 ? 0.0 : (currentCount / targetCount).clamp(0.0, 1.0);
  bool get isCompleted => currentCount >= targetCount;
  int get totalAdhkar => adhkar.length;

  TasbihDhikr? get currentDhikr =>
      adhkar.isEmpty ? null : adhkar[currentDhikrIndex];
  String get currentDhikrText => currentDhikr?.text ?? '';
  String? get currentDhikrVirtue => currentDhikr?.virtue;

  TasbihState copyWith({
    TasbihStatus? status,
    List<TasbihDhikr>? adhkar,
    int? currentDhikrIndex,
    int? currentCount,
    int? completedRounds,
    int? totalCount,
    bool? justCompletedRound,
  }) {
    return TasbihState(
      status: status ?? this.status,
      adhkar: adhkar ?? this.adhkar,
      currentDhikrIndex: currentDhikrIndex ?? this.currentDhikrIndex,
      currentCount: currentCount ?? this.currentCount,
      completedRounds: completedRounds ?? this.completedRounds,
      totalCount: totalCount ?? this.totalCount,
      justCompletedRound: justCompletedRound ?? this.justCompletedRound,
    );
  }

  @override
  List<Object?> get props => [
    status,
    adhkar,
    currentDhikrIndex,
    currentCount,
    completedRounds,
    totalCount,
    justCompletedRound,
  ];
}