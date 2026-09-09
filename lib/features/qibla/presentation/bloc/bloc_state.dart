import 'package:equatable/equatable.dart';

import '../../domain/entities/qibla_entity.dart';

enum QiblaStatus {
  initial,
  loading,
  loaded,
  error,
}

class QiblaState extends Equatable {
  final QiblaStatus status;
  final QiblaEntity? qibla;
  final String? errorMessage;

  const QiblaState({
    this.status = QiblaStatus.initial,
    this.qibla,
    this.errorMessage,
  });

  QiblaState copyWith({
    QiblaStatus? status,
    QiblaEntity? qibla,
    String? errorMessage,
    bool clearError = false,
  }) {
    return QiblaState(
      status: status ?? this.status,
      qibla: qibla ?? this.qibla,
      errorMessage:
      clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    qibla,
    errorMessage,
  ];
}