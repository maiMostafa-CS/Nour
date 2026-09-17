import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';

class QuranSearchPage extends StatefulWidget {
  const QuranSearchPage({super.key});

  @override
  State<QuranSearchPage> createState() => _QuranSearchPageState();
}

class _QuranSearchPageState extends State<QuranSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _results = [];

  bool _searched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

// ============================================================
// البحث
// ============================================================

  void _search() {
    final String query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }

    try {
      final Map result = searchWords(query);

      final List<dynamic> rawResults = result['result'] ?? [];

      final List<Map<String, dynamic>> results = [];

      for (final item in rawResults) {
        final surahNumber = int.tryParse(
          item['suraNumber'].toString(),
        );

        final verseNumber = int.tryParse(
          item['verseNumber'].toString(),
        );

        if (surahNumber == null || verseNumber == null) {
          continue;
        }

        results.add({
          'surahNumber': surahNumber,
          'verseNumber': verseNumber,
        });
      }

      setState(() {
        _results = results;
        _searched = true;
      });

      debugPrint(
        'QURAN SEARCH: "$query" -> ${results.length} results',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'QURAN SEARCH ERROR: $e',
      );

      debugPrint(
        stackTrace.toString(),
      );

      setState(() {
        _results = [];
        _searched = true;
      });
    }
  }

// ============================================================
// توحيد النص العربي
// ============================================================

  String _normalizeSearchText(String text) {
    String value = text;

// إزالة التشكيل
    value = value.replaceAll(
      RegExp(r'[\u064B-\u065F\u0670]'),
      '',
    );

// إزالة علامات القرآن
    value = value.replaceAll(
      RegExp(r'[\u0610-\u061A\u06D6-\u06ED]'),
      '',
    );

// توحيد الألف
    value =
        value.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا');

// توحيد الياء
    value = value.replaceAll('ى', 'ي').replaceAll('ئ', 'ي');

// توحيد الواو بالهمزة
    value = value.replaceAll('ؤ', 'و');

// التاء المربوطة
    value = value.replaceAll('ة', 'ه');

// إزالة التطويل
    value = value.replaceAll('ـ', '');

// إزالة المسافات الزائدة
    value = value.replaceAll(RegExp(r'\s+'), ' ');

    return value.trim().toLowerCase();
  }

// ============================================================
// فتح الآية
// ============================================================

  void _openVerse(
    int surahNumber,
    int verseNumber,
  ) {
    try {
      final int pageNumber = getPageNumber(
        surahNumber,
        verseNumber,
      );

      Navigator.pop(
        context,
        pageNumber,
      );
    } catch (e) {
      debugPrint(
        'ERROR OPENING VERSE: $e',
      );
    }
  }

// ============================================================
// UI
// ============================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF5D7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFCF5D7),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'بحث في القرآن',
            style: TextStyle(
              color: Color(0xFF8B5A2B),
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFF8B5A2B),
          ),
        ),
        body: Column(
          children: [
// ====================================================
// Search field
// ====================================================

            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                textInputAction: TextInputAction.search,
                onChanged: (_) => _search(),
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'ابحث في القرآن...',
                  hintTextDirection: TextDirection.rtl,
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Color(0xFF8B5A2B),
                    ),
                    onPressed: _search,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF3E5C8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

// ====================================================
// Results
// ====================================================

            Expanded(
              child: !_searched
                  ? const Center(
                      child: Text(
                        'اكتب كلمة للبحث في القرآن',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8B5A2B),
                        ),
                      ),
                    )
                  : _results.isEmpty
                      ? const Center(
                          child: Text(
                            'لا توجد نتائج',
                            style: TextStyle(
                              fontSize: 17,
                              color: Color(0xFF8B5A2B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const SizedBox(
                            height: 8,
                          ),
                          itemBuilder: (context, index) {
                            final item = _results[index];

                            final int surahNumber = item['surahNumber'];

                            final int verseNumber = item['verseNumber'];

                            final String surahName = getSurahNameArabic(
                              surahNumber,
                            );

                            final String verseText = getVerse(
                              surahNumber,
                              verseNumber,
                            );

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                  16,
                                ),
                                onTap: () {
                                  _openVerse(
                                    surahNumber,
                                    verseNumber,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFF3E5C8,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      16,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
// =================================
// Surah + Ayah
// =================================

                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color(
                                                  0xFF8B5A2B,
                                                ),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                20,
                                              ),
                                            ),
                                            child: Text(
                                              '$surahName • آية $verseNumber',
                                              style: const TextStyle(
                                                color: Color(
                                                  0xFF8B5A2B,
                                                ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(
                                            Icons.arrow_back_ios,
                                            size: 16,
                                            color: Color(
                                              0xFF8B5A2B,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                        height: 10,
                                      ),

// =================================
// Verse
// =================================

                                      Text(
                                        verseText,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          height: 1.8,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
