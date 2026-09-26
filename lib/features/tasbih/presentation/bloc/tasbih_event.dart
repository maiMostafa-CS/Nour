// lib/features/tasbih/bloc/tasbih_event.dart

import 'package:equatable/equatable.dart';

abstract class TasbihEvent extends Equatable {
  const TasbihEvent();
  @override
  List<Object?> get props => [];
}

class TasbihLoadRequested extends TasbihEvent {
  const TasbihLoadRequested();
}

class TasbihIncremented extends TasbihEvent {
  const TasbihIncremented();
}

class TasbihReset extends TasbihEvent {
  const TasbihReset();
}

class TasbihResetAll extends TasbihEvent {
  const TasbihResetAll();
}

class TasbihNextDhikr extends TasbihEvent {
  const TasbihNextDhikr();
}

class TasbihPreviousDhikr extends TasbihEvent {
  const TasbihPreviousDhikr();
}

class TasbihDhikrSelected extends TasbihEvent {
  final int index;
  const TasbihDhikrSelected(this.index);
  @override
  List<Object?> get props => [index];
}

class TasbihRoundCompletedConsumed extends TasbihEvent {
  const TasbihRoundCompletedConsumed();
}

class TasbihCustomDhikrAdded extends TasbihEvent {
  final String text;
  final String? virtue;
  final int targetCount; // ✨ جديد
  const TasbihCustomDhikrAdded({
    required this.text,
    this.virtue,
    this.targetCount = 100,
  });
  @override
  List<Object?> get props => [text, virtue, targetCount];
}

class TasbihCustomDhikrDeleted extends TasbihEvent {
  final int dhikrId;
  const TasbihCustomDhikrDeleted(this.dhikrId);
  @override
  List<Object?> get props => [dhikrId];
}

// ✨ جديد: تغيير العدد المستهدف للذكر الحالي
class TasbihTargetCountChanged extends TasbihEvent {
  final int newTarget;
  const TasbihTargetCountChanged(this.newTarget);
  @override
  List<Object?> get props => [newTarget];
}