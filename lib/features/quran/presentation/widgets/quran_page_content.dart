import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qcf_quran/qcf_quran.dart';

import '../../../../core/data/quran/quran_helpers.dart';


class QuranPageContent extends StatefulWidget {
  final int pageNumber;
  final PageController? controller;

  final void Function({
  required int pageNumber,
  required String surahName,
  required int? juz,
  required int? hizb,
  int? rub,
  })? onPageInfoLoaded;

  const QuranPageContent({
    super.key,
    required this.pageNumber,
    this.onPageInfoLoaded,
    this.controller
  });

  @override
  State<QuranPageContent> createState() => _QuranPageContentState();
}

class _QuranPageContentState extends State<QuranPageContent> {
  late final PageController _controller;

  int _currentPage = 1;
  String _currentSurahName = '';
  int? _currentJuz;

  @override
  void initState() {
    super.initState();

    _currentPage = widget.pageNumber;

    _controller = PageController(
      initialPage: widget.pageNumber - 1,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportPageInfo(widget.pageNumber);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final double offsetY = _currentPage <= 2 ? -40 : 10.0;
    final bool isFirstTwoPages = _currentPage <= 2;
    return Transform.translate(
      offset: Offset(0, offsetY),
      child:
      PageviewQuran(
        pageBackgroundColor: const Color(0xFFFCF5D7),
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
       sp: .9.w,
        h:
        // 1.4.h,
        1.h,
        onPageChanged: (pageNumber) {
          _reportPageInfo(pageNumber);
        },
      ),
    );
  }



  void _reportPageInfo(int pageNumber ) {
    if (pageNumber < 1 || pageNumber > 604) {
      return;
    }

    final pageData = getPageData(pageNumber);

    debugPrint('══════════════════════════════════');
    debugPrint('📖 الصفحة: $pageNumber');
    debugPrint('📦 pageData: $pageData');

    if (pageData.isEmpty) {
      return;
    }

    final firstItem = pageData.first;

    final int? surahNumber = firstItem['surah'] as int?;
    final int? verseNumber = firstItem['start'] as int?;

    if (surahNumber == null || verseNumber == null) {
      debugPrint(
        '⚠️ بيانات الصفحة غير مكتملة: '
            'page=$pageNumber, '
            'surah=$surahNumber, '
            'start=$verseNumber',

      );
      return;
    }

    final String surahName = getSurahNameArabic(surahNumber);

final  int juz = getJuzNumber(surahNumber, verseNumber);
    final hizbNumber = getHizbNumber(
      surahNumber,
      verseNumber,
    );
    debugPrint('📄 رقم الصفحة: $pageNumber');
    debugPrint('📕 السورة: $surahName');
    debugPrint('🟢 الجزء: $juz');
    debugPrint('🟢 الحزب: $hizbNumber');


    if (mounted) {
      setState(() {
        _currentPage = pageNumber;
        _currentSurahName = surahName;
        _currentJuz = juz;
      });
    }

    widget.onPageInfoLoaded?.call(
      pageNumber: pageNumber,
      surahName: surahName,
      juz: juz,
      hizb: hizbNumber ,
      rub: null,
    );
  }

}
