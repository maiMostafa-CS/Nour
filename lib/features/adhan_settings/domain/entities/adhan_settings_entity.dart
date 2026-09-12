import 'package:equatable/equatable.dart';

class AdhanSettingsEntity extends Equatable {
  final bool fajr;
  final bool sunrise;
  final bool dhuhr;
  final bool asr;
  final bool maghrib;
  final bool isha;

  const AdhanSettingsEntity({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  /// Default settings:
  ///
  /// Fajr      ON
  /// Sunrise   OFF
  /// Dhuhr     ON
  /// Asr       ON
  /// Maghrib   ON
  /// Isha      ON
  factory AdhanSettingsEntity.defaults() {
    return const AdhanSettingsEntity(
      fajr: true,
      sunrise: false,
      dhuhr: true,
      asr: true,
      maghrib: true,
      isha: true,
    );
  }

  /// Returns whether adhan is enabled for a prayer index.
  ///
  /// 0 = Fajr
  /// 1 = Sunrise
  /// 2 = Dhuhr
  /// 3 = Asr
  /// 4 = Maghrib
  /// 5 = Isha
  bool isEnabled(int index) {
    switch (index) {
      case 0:
        return fajr;
      case 1:
        return sunrise;
      case 2:
        return dhuhr;
      case 3:
        return asr;
      case 4:
        return maghrib;
      case 5:
        return isha;
      default:
        return false;
    }
  }

  AdhanSettingsEntity copyWith({
    bool? fajr,
    bool? sunrise,
    bool? dhuhr,
    bool? asr,
    bool? maghrib,
    bool? isha,
  }) {
    return AdhanSettingsEntity(
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
    );
  }

  @override
  List<Object?> get props => [
    fajr,
    sunrise,
    dhuhr,
    asr,
    maghrib,
    isha,
  ];
}