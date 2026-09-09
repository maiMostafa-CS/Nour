import 'package:equatable/equatable.dart';

class AyahEntity extends Equatable {
  final int number;
  final String text;
  const AyahEntity({required this.number, required this.text});
  @override List<Object?> get props => [number, text];
}

class SurahEntity extends Equatable {
  final int number;
  final String name;
  final String englishName;
  final List<AyahEntity> ayahs;

  const SurahEntity({
    required this.number,
    required this.name,
    required this.englishName,
    required this.ayahs,
  });

  @override List<Object?> get props => [number, name, englishName, ayahs];
}
