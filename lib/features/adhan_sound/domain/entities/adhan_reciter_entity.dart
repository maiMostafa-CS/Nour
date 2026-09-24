import 'package:equatable/equatable.dart';

class AdhanReciterEntity extends Equatable {
  final String id;
  final String name;
  final String normalAdhanAssetPath;

  const AdhanReciterEntity({
    required this.id,
    required this.name,
    required this.normalAdhanAssetPath,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    normalAdhanAssetPath,
  ];
}