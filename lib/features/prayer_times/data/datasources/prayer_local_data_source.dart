import 'package:adhan_dart/adhan_dart.dart';

import '../models/prayer_times_model.dart';

abstract class PrayerLocalDataSource {
  PrayerTimesModel calculate({
    required double latitude,
    required double longitude,
    required DateTime date,
  });
}

class PrayerLocalDataSourceImpl implements PrayerLocalDataSource {
  @override
  PrayerTimesModel calculate({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) {
    final coordinates = Coordinates(
      latitude,
      longitude,
    );

    final params = CalculationMethodParameters.egyptian()
      ..madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: date,
      calculationParameters: params,
      precision: true,
    );

    print('════════ ADHAN DEBUG ════════');
    print('DATE INPUT       = $date');
    print('FAJR RAW         = ${prayerTimes.fajr}');
    print('FAJR TO DEVICE LOCAL = ${prayerTimes.fajr.toLocal()}');
    print('FAJR UTC         = ${prayerTimes.fajr.toUtc()}');

    print('SUNRISE RAW      = ${prayerTimes.sunrise}');
    print('DHUHR RAW        = ${prayerTimes.dhuhr}');
    print('ASR RAW          = ${prayerTimes.asr}');
    print('MAGHRIB RAW      = ${prayerTimes.maghrib}');
    print('ISHA RAW         = ${prayerTimes.isha}');
    print('════════════════════════════');
    return PrayerTimesModel(
      fajr: prayerTimes.fajr,
      sunrise: prayerTimes.sunrise,
      dhuhr: prayerTimes.dhuhr,
      asr: prayerTimes.asr,
      maghrib: prayerTimes.maghrib,
      isha: prayerTimes.isha,
    );
  }
}