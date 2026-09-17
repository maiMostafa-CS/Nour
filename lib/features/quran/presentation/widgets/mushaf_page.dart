import 'package:flutter/material.dart';
import 'package:islamic_app/features/quran/presentation/widgets/quran_page_content.dart';

class MushafPage extends StatefulWidget {
  final int startPage;

  const MushafPage({
    super.key,
    required this.startPage,
  });

  @override
  State<MushafPage> createState() => MushafPageState();
}

class MushafPageState extends State<MushafPage> {
  late final PageController _controller;

  late int _currentPage;

  String _currentSurahName = 'المصحف الشريف';

  int _currentJuz = 1;
  int _currentHizb = 1;
  int? _currentRub;

  @override
  void initState() {
    super.initState();

    _currentPage = widget.startPage;

    _controller = PageController(
      initialPage: widget.startPage - 1,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // تحديث معلومات الصفحة
  // ============================================================

  void _updatePageInfo({
    required String surahName,
    required int? juz,
    required int? hizb,
    int? rub,
  }) {
    if (!mounted) return;

    if (_currentSurahName == surahName &&
        _currentJuz == juz &&
        _currentHizb == hizb &&
        _currentRub == rub) {
      return;
    }

    setState(() {
      _currentSurahName = surahName;
      _currentJuz = juz!;
      _currentHizb = hizb!;
      _currentRub = rub;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF5D7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF5D7),
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 40,
        titleSpacing: 8,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الجزء ${_currentJuz ?? '-'}',
              style: const TextStyle(
                fontSize: 13,               // ← صغّر شوية
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _currentSurahName,
              style: const TextStyle(
                fontSize: 16,               // ← صغّر شوية
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'الحزب ${_currentHizb ?? '-'}',
              style: const TextStyle(
                fontSize: 13,               // ← صغّر شوية
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: 604,
                reverse: true,
                physics: const PageScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index + 1;
                  });
                },
                itemBuilder: (context, index) {
                  final pageNumber = index + 1;
                  return QuranPageContent(
                    pageNumber: pageNumber,
                    onPageInfoLoaded: _updatePageInfo,
                  );
                },
              ),
            ),
            SizedBox(
              height: 28,
              child: Center(
                child: Text(
                  '$_currentPage',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}