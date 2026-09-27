import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/errors/no_internet_exception.dart';
import '../model/quran_tafsir_book_model.dart';
import '../model/quran_tafsir_model.dart';

abstract class QuranpediaRemoteDataSource {
  Future<List<QuranTafsirBookModel>> getTafsirBooks({
    required int surahNumber,
  });

  Future<QuranTafsirModel?> getAyahTafsir({
    required int surahNumber,
    required int ayahNumber,
    required int bookId,
  });
}

class QuranpediaRemoteDataSourceImpl implements QuranpediaRemoteDataSource {
  static const String _baseUrl = 'https://api.quran.com/api/v4';

  // Arabic names for tafsirs (key: tafsir identifier in Quran.com).
  // Check the identifiers from the log (🔎) and correct them if they differ.
  static const Map<int, Map<String, String>> _arabicMeta = {
    14: {'name': 'تفسير ابن كثير', 'author': 'ابن كثير'},
    15: {'name': 'تفسير الطبري', 'author': 'ابن جرير الطبري'},
    16: {'name': 'التفسير الميسر', 'author': 'نخبة من العلماء'},
    90: {'name': 'تفسير القرطبي', 'author': 'القرطبي'},
    91: {'name': 'تفسير السعدي', 'author': 'عبد الرحمن السعدي'},
    93: {'name': 'التفسير الوسيط', 'author': 'محمد سيد طنطاوي'},
    94: {'name': 'تفسير البغوي', 'author': 'البغوي'},
  };

  final http.Client client;

  List<QuranTafsirBookModel>? _cachedBooks;

  QuranpediaRemoteDataSourceImpl({required this.client});

  Future<http.Response> _get(Uri uri) async {
    try {
      return await client.get(uri).timeout(const Duration(seconds: 15));
    } on SocketException {
      throw const NoInternetException();
    } on http.ClientException {

      throw const NoInternetException();
    } on TimeoutException {
      throw const NoInternetException(
        'انتهت مهلة الاتصال، تأكد من الإنترنت وحاول مرة أخرى',
      );
    }
  }

  @override
  Future<List<QuranTafsirBookModel>> getTafsirBooks({
    required int surahNumber, // غير مستخدم: Quran.com لا يربط التفاسير بسورة
  }) async {
    if (_cachedBooks != null) return _cachedBooks!;

    final uri = Uri.parse('$_baseUrl/resources/tafsirs');
    debugPrint('📡 Tafsir books URL: $uri');
    final response = await _get(uri);
    // final response = await client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load tafsir books: ${response.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is! Map<String, dynamic> || decoded['tafsirs'] is! List) {
      debugPrint('❌ Unexpected tafsirs response shape');
      return [];
    }

    final books = <QuranTafsirBookModel>[];

    for (final item in decoded['tafsirs'] as List) {
      if (item is! Map) continue;

      final raw = Map<String, dynamic>.from(item);

      // Take Arabic tafsirs only
      final language = raw['language_name']?.toString().toLowerCase();
      if (language != 'arabic') {
        debugPrint('⏭️ Skipping non-Arabic tafsir: ${raw['name']} ($language)');
        continue;
      }

      final id = (raw['id'] as num?)?.toInt() ?? 0;

      // Print the actual data to fix the mapping
      debugPrint('🔎 id=$id slug=${raw['slug']} name=${raw['name']}');

      final meta = _arabicMeta[id];

      // If there is no Arabic name, do not show the book (to avoid displaying an English name)
      if (meta == null) {
        debugPrint('⏭️ No Arabic meta for id=$id, skipping');
        continue;
      }

      final json = <String, dynamic>{
        'id': id,
        'name': meta['name'],
        'author': meta['author'],
        'slug': raw['slug'],
        'type': 'tafsir',
      };

      try {
        books.add(QuranTafsirBookModel.fromJson(json));
      } catch (e, st) {
        debugPrint('❌ Failed to parse tafsir book: $e\n$st');
      }
    }

    debugPrint('📚 Arabic tafsir books count: ${books.length}');
    _cachedBooks = books;
    return books;
  }

  @override
  Future<QuranTafsirModel?> getAyahTafsir({
    required int surahNumber,
    required int ayahNumber,
    required int bookId,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/tafsirs/$bookId/by_ayah/$surahNumber:$ayahNumber',
    );

    final response = await _get(uri);

    if (response.statusCode == 404) return null;

    if (response.statusCode != 200) {
      throw Exception('Failed to load tafsir: ${response.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is! Map<String, dynamic>) return null;

    final tafsir = decoded['tafsir'];
    if (tafsir is! Map) return null;

    final text = _cleanArabicText(tafsir['text']?.toString() ?? '');
    if (text.trim().isEmpty) return null;

    // The author name is not present in this response, so use it from the stored list if available
    QuranTafsirBookModel? cachedBook;
    for (final b in _cachedBooks ?? const <QuranTafsirBookModel>[]) {
      if (b.id == bookId) {
        cachedBook = b;
        break;
      }
    }

    final meta = _arabicMeta[bookId];

    // Build the same shape expected by QuranTafsirModel.fromJson
    return QuranTafsirModel.fromJson({
      'book': {
        'id': bookId,
        'name': cachedBook?.name ?? meta?['name'] ?? '',
        'author': cachedBook?.author ?? meta?['author'],
      },
      'content': [
        {'text': text},
      ],
    });
  }

  /// Clean tafsir text: remove HTML and English-only lines
  String _cleanArabicText(String input) {
    final noHtml = input
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&');

    final hasArabic = RegExp(r'[\u0600-\u06FF]');
    final hasLatin = RegExp(r'[A-Za-z]');

    final lines = noHtml.split('\n').where((line) {
      final l = line.trim();
      if (l.isEmpty) return true;
      // Remove the line if it contains Latin letters and no Arabic
      return !(hasLatin.hasMatch(l) && !hasArabic.hasMatch(l));
    });

    return lines.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }
}