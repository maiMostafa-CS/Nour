import 'package:equatable/equatable.dart';

class AdhanReciterEntity extends Equatable {
  final String id;
  final String name;
  final String normalAdhanAssetPath;
  final String fajrAdhanAssetPath;

  const AdhanReciterEntity({
    required this.id,
    required this.name,
    required this.normalAdhanAssetPath,
    required this.fajrAdhanAssetPath,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    normalAdhanAssetPath,
    fajrAdhanAssetPath,
  ];
}