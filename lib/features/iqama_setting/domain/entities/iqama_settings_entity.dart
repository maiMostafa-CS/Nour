import 'package:equatable/equatable.dart';

class IqamaSettingsEntity extends Equatable {
  final int fajr;
  final int sunrise;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;

  const IqamaSettingsEntity({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory IqamaSettingsEntity.defaults() {
    return const IqamaSettingsEntity(
      fajr: 15,
      sunrise: 15,
      dhuhr: 15,
      asr: 15,
      maghrib: 15,
      isha: 15,
    );
  }

  int getMinutes(int prayerIndex) {
    switch (prayerIndex) {
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
        return 15;
    }
  }

  IqamaSettingsEntity copyWith({
    int? fajr,
    int? sunrise,
    int? dhuhr,
    int? asr,
    int? maghrib,
    int? isha,
  }) {
    return IqamaSettingsEntity(
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