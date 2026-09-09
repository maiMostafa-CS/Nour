import 'package:equatable/equatable.dart';

class DhikrEntity extends Equatable {
  final String id;
  final String category;
  final String text;
  final int count;
  final String reference;
  final String audio;

  const DhikrEntity({
    required this.id,
    required this.category,
    required this.text,
    required this.count,
    required this.reference,
    required this.audio,
  });

  @override
  List<Object?> get props => [
    id,
    category,
    text,
    count,
    reference,
    audio,
  ];
}