import '../../domain/entities/khatma_progress.dart';

class KhatmaProgressModel extends KhatmaProgress {
  const KhatmaProgressModel({
    required super.currentAyah,
    required super.readAyahs,
  });

  factory KhatmaProgressModel.fromPrefs({
    required int currentAyah,
    required int readAyahs,
  }) {
    return KhatmaProgressModel(
      currentAyah: currentAyah,
      readAyahs: readAyahs,
    );
  }

  factory KhatmaProgressModel.fromEntity(
      KhatmaProgress entity,
      ) {
    return KhatmaProgressModel(
      currentAyah: entity.currentAyah,
      readAyahs: entity.readAyahs,
    );
  }

  KhatmaProgressModel copyWith({
    int? currentAyah,
    int? readAyahs,
  }) {
    return KhatmaProgressModel(
      currentAyah: currentAyah ?? this.currentAyah,
      readAyahs: readAyahs ?? this.readAyahs,
    );
  }
}