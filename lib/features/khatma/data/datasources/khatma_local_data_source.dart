import 'package:shared_preferences/shared_preferences.dart';

import '../model/khatma_progress_model.dart';

abstract class KhatmaLocalDataSource {
  Future<KhatmaProgressModel> getProgress();

  Future<KhatmaProgressModel> markCurrentAyahAsRead();

  Future<void> reset();
}

class KhatmaLocalDataSourceImpl implements KhatmaLocalDataSource {
  final SharedPreferences prefs;

  KhatmaLocalDataSourceImpl(this.prefs);

  static const String _currentAyahKey = 'khatma_current_ayah';
  static const String _readAyahsKey = 'khatma_read_ayahs';

  static const int totalAyahs = 6236;

  @override
  Future<KhatmaProgressModel> getProgress() async {
    final currentAyah = prefs.getInt(_currentAyahKey) ?? 1;
    final readAyahs = prefs.getInt(_readAyahsKey) ?? 0;

    return KhatmaProgressModel.fromPrefs(
      currentAyah: currentAyah,
      readAyahs: readAyahs,
    );
  }

  @override
  Future<KhatmaProgressModel> markCurrentAyahAsRead() async {
    final progress = await getProgress();

    if (progress.currentAyah > totalAyahs) {
      return progress;
    }

    final newCurrentAyah = progress.currentAyah + 1;
    final newReadAyahs = progress.readAyahs + 1;

    await prefs.setInt(
      _currentAyahKey,
      newCurrentAyah,
    );

    await prefs.setInt(
      _readAyahsKey,
      newReadAyahs,
    );

    return progress.copyWith(
      currentAyah: newCurrentAyah,
      readAyahs: newReadAyahs,
    );
  }

  @override
  Future<void> reset() async {
    await prefs.remove(_currentAyahKey);
    await prefs.remove(_readAyahsKey);
  }
}