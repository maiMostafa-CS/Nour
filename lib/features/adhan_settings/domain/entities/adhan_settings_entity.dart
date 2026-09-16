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

  /// Helper: يرجع نسخة جديدة مع تغيير صلاة واحدة فقط
  AdhanSettingsEntity toggle(int index, bool enabled) {
    final values = <bool>[
      fajr,
      sunrise,
      dhuhr,
      asr,
      maghrib,
      isha,
    ];

    values[index] = enabled;

    return copyWith(
      fajr: values[0],
      sunrise: values[1],
      dhuhr: values[2],
      asr: values[3],
      maghrib: values[4],
      isha: values[5],
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