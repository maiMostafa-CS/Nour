import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/dhikr_entity.dart';

abstract class AdhkarLocalDataSource {
  Future<List<DhikrEntity>> getAdhkar();
}

class AdhkarLocalDataSourceImpl implements AdhkarLocalDataSource {
  @override
  Future<List<DhikrEntity>> getAdhkar() async {

      final raw = await rootBundle.loadString(
        'assets/adhkar/adhkar.json',
      );
      final decoded = jsonDecode(raw);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'adhkar.json يجب أن يكون Map<String, dynamic>',
        );
      }

      final List<DhikrEntity> adhkar = [];

      int categoryIndex = 0;
      int dhikrIndex = 0;

      for (final entry in decoded.entries) {
        categoryIndex++;

        final category = entry.key;
        final value = entry.value;

        if (value is! Map<String, dynamic>) {
          continue;
        }

        final audio = value['Audio']?.toString() ?? '';

        final adhkarList = value['Adhkar'];

        if (adhkarList is! List) {
          continue;
        }

        for (final item in adhkarList) {
          if (item is! Map<String, dynamic>) {
            continue;
          }

          final text = item['Text']?.toString() ?? '';
          final count = _parseCount(item['Count']);
          final reference = item['Reference']?.toString() ?? '';

          if (text.trim().isEmpty) {
            continue;
          }

          final dhikr = DhikrEntity(
            id: 'dhikr_${dhikrIndex++}',
            category: category,
            text: text,
            count: count,
            reference: reference,
            audio: audio,
          );

          adhkar.add(dhikr);

        }
      }

      return adhkar;
    }
  }

  int _parseCount(dynamic value) {
    if (value == null) {
      return 1;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 1;
    }

    return 1;
  }
