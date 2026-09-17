import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/surah_model.dart';


abstract class QuranIndexLocalDataSource {
  Future<List<SurahModel>> getSurahs();
}

class QuranIndexLocalDataSourceImpl
    implements QuranIndexLocalDataSource {
  static const String _jsonPath = 'assets/quran/surah.json';

  @override
  Future<List<SurahModel>> getSurahs() async {
    final jsonString = await rootBundle.loadString(_jsonPath);

    final dynamic decodedData = jsonDecode(jsonString);

    if (decodedData is! List) {
      throw const FormatException(
        'quran_name.json must contain a JSON array.',
      );
    }

    return decodedData
        .map(
          (item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException(
            'Invalid surah object in quran_name.json.',
          );
        }

        return SurahModel.fromJson(item);
      },
    )
        .toList();
  }
}