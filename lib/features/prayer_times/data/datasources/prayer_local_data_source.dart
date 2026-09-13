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
  @override
  PrayerTimesModel calculate({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) {
    final coordinates = Coordinates(latitude, longitude);

    final params = CalculationMethodParameters.egyptian()
      ..madhab = Madhab.shafi;



    final prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: date,
      calculationParameters: params,
      precision: true,
    );

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