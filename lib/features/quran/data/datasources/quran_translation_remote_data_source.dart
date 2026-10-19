import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/errors/no_internet_exception.dart';
import '../model/quran_translation_model.dart';
import '../model/quran_translation_resource_model.dart';

abstract class QuranTranslationRemoteDataSource {
  Future<List<QuranTranslationResourceModel>> getTranslationResources({
    String language = 'english',
  });

  Future<QuranTranslationModel?> getAyahTranslation({
    required int surahNumber,
    required int ayahNumber,
    required int resourceId,
  });

  Future<List<QuranTranslationModel>> getChapterTranslation({
    required int chapterNumber,
    required int resourceId,
  });
}

class QuranTranslationRemoteDataSourceImpl
    implements QuranTranslationRemoteDataSource {
  static const String _baseUrl = 'https://api.quran.com/api/v4';

  final http.Client client;

  List<QuranTranslationResourceModel>? _cachedResources;

  // Preset English translations for instant availability and offline resilience
  static const List<QuranTranslationResourceModel> defaultEnglishResources = [
    QuranTranslationResourceModel(
      id: 20,
      name: 'Saheeh International',
      authorName: 'Saheeh International',
      languageName: 'english',
    ),
    QuranTranslationResourceModel(
      id: 85,
      name: 'M.A.S. Abdel Haleem',
      authorName: 'M.A.S. Abdel Haleem',
      languageName: 'english',
    ),
    QuranTranslationResourceModel(
      id: 22,
      name: 'A. Yusuf Ali',
      authorName: 'Abdullah Yusuf Ali',
      languageName: 'english',
    ),
    QuranTranslationResourceModel(
      id: 19,
      name: 'M. Pickthall',
      authorName: 'Mohammed Marmaduke William Pickthall',
      languageName: 'english',
    ),
    QuranTranslationResourceModel(
      id: 84,
      name: 'Mufti Taqi Usmani',
      authorName: 'Mufti Taqi Usmani',
      languageName: 'english',
    ),
    QuranTranslationResourceModel(
      id: 149,
      name: 'Bridges’ Translation',
      authorName: 'Fadel Soliman',
      languageName: 'english',
    ),
    QuranTranslationResourceModel(
      id: 203,
      name: 'Al-Hilali & Khan',
      authorName: 'Muhammad Taqi-ud-Din al-Hilali & Muhammad Muhsin Khan',
      languageName: 'english',
    ),
  ];

  QuranTranslationRemoteDataSourceImpl({required this.client});

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
  Future<List<QuranTranslationResourceModel>> getTranslationResources({
    String language = 'english',
  }) async {
    if (_cachedResources != null && _cachedResources!.isNotEmpty) {
      return _cachedResources!;
    }

    try {
      final uri = Uri.parse('$_baseUrl/resources/translations');
      debugPrint('📡 Fetching translation resources: $uri');
      final response = await _get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic> && decoded['translations'] is List) {
          final targetLanguage = language.toLowerCase();
          final list = <QuranTranslationResourceModel>[];

          for (final item in decoded['translations'] as List) {
            if (item is! Map) continue;
            final map = Map<String, dynamic>.from(item);
            final lang = map['language_name']?.toString().toLowerCase() ?? '';

            if (lang == targetLanguage) {
              list.add(QuranTranslationResourceModel.fromJson(map));
            }
          }

          if (list.isNotEmpty) {
            _cachedResources = list;
            return list;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching translation resources from API: $e');
    }

    // Fallback to presets if network failed or language matched english
    _cachedResources = defaultEnglishResources;
    return defaultEnglishResources;
  }

  @override
  Future<QuranTranslationModel?> getAyahTranslation({
    required int surahNumber,
    required int ayahNumber,
    required int resourceId,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/quran/translations/$resourceId?verse_key=$surahNumber:$ayahNumber',
    );
    debugPrint('📡 Fetching ayah translation: $uri');

    final response = await _get(uri);

    if (response.statusCode == 404) return null;

    if (response.statusCode != 200) {
      throw Exception('Failed to load translation: ${response.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) return null;

    final translations = decoded['translations'];
    if (translations is! List || translations.isEmpty) return null;

    final first = translations.first;
    if (first is! Map) return null;

    final rawText = first['text']?.toString() ?? '';
    final cleanedText = _cleanTranslationText(rawText);

    if (cleanedText.trim().isEmpty) return null;

    // Look up fallback resource info
    QuranTranslationResourceModel? cachedResource;
    for (final r in _cachedResources ?? defaultEnglishResources) {
      if (r.id == resourceId) {
        cachedResource = r;
        break;
      }
    }

    final meta = decoded['meta'] is Map ? decoded['meta'] as Map : null;
    final translationName = meta?['translation_name']?.toString() ??
        cachedResource?.name ??
        '';
    final authorName = meta?['author_name']?.toString() ??
        cachedResource?.authorName ??
        '';

    return QuranTranslationModel(
      resourceId: resourceId,
      translationName: translationName,
      authorName: authorName,
      text: cleanedText,
      ayahNumber: ayahNumber,
    );
  }

  @override
  Future<List<QuranTranslationModel>> getChapterTranslation({
    required int chapterNumber,
    required int resourceId,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/quran/translations/$resourceId?chapter_number=$chapterNumber',
    );
    debugPrint('📡 Fetching chapter translation: $uri');

    final response = await _get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load chapter translation: ${response.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) return [];

    final translations = decoded['translations'];
    if (translations is! List || translations.isEmpty) return [];

    // Look up fallback resource info
    QuranTranslationResourceModel? cachedResource;
    for (final r in _cachedResources ?? defaultEnglishResources) {
      if (r.id == resourceId) {
        cachedResource = r;
        break;
      }
    }

    final meta = decoded['meta'] is Map ? decoded['meta'] as Map : null;
    final translationName = meta?['translation_name']?.toString() ??
        cachedResource?.name ??
        '';
    final authorName = meta?['author_name']?.toString() ??
        cachedResource?.authorName ??
        '';

    final result = <QuranTranslationModel>[];
    for (var i = 0; i < translations.length; i++) {
      final item = translations[i];
      if (item is! Map) continue;
      final rawText = item['text']?.toString() ?? '';
      final cleanedText = _cleanTranslationText(rawText);

      result.add(
        QuranTranslationModel(
          resourceId: resourceId,
          translationName: translationName,
          authorName: authorName,
          text: cleanedText,
          ayahNumber: i + 1,
        ),
      );
    }

    return result;
  }

  /// Clean translation text: strip footnote elements, HTML tags, and HTML entities
  String _cleanTranslationText(String input) {
    var text = input;

    // Strip <sup ...>...</sup> footnotes entirely
    text = text.replaceAll(RegExp(r'<sup[^>]*>.*?</sup>', caseSensitive: false), '');

    // Strip other html tags (e.g. <b>, <i>, <p>, etc.)
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');

    // Replace common HTML entities
    text = text
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    // Clean whitespace
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
