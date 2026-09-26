// lib/features/tasbih/models/tasbih_model.dart

class TasbihDhikr {
  final int id;
  final String text;
  final String? virtue;
  final bool isCustom;
  final int targetCount; // ✨ جديد: العدد المستهدف لكل ذكر

  const TasbihDhikr({
    required this.id,
    required this.text,
    this.virtue,
    this.isCustom = false,
    this.targetCount = 100, // القيمة الافتراضية
  });

  TasbihDhikr copyWith({
    int? id,
    String? text,
    String? virtue,
    bool? isCustom,
    int? targetCount,
  }) {
    return TasbihDhikr(
      id: id ?? this.id,
      text: text ?? this.text,
      virtue: virtue ?? this.virtue,
      isCustom: isCustom ?? this.isCustom,
      targetCount: targetCount ?? this.targetCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'virtue': virtue,
    'isCustom': isCustom,
    'targetCount': targetCount,
  };

  factory TasbihDhikr.fromJson(Map<String, dynamic> json) => TasbihDhikr(
    id: json['id'] as int,
    text: json['text'] as String,
    virtue: json['virtue'] as String?,
    isCustom: json['isCustom'] as bool? ?? false,
    targetCount: json['targetCount'] as int? ?? 100,
  );
}