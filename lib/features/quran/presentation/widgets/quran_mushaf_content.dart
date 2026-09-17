import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../domain/entities/surah_entity.dart';


// ═══════════════════════════════════════════════════════
// 1. _Segment
// ═══════════════════════════════════════════════════════
class _Segment {
  final int surahNumber;
  final List<AyahEntity> ayahs;
  final bool isNewSurah;

  _Segment({
    required this.surahNumber,
    required this.ayahs,
    required this.isNewSurah,
  });
}

// ═══════════════════════════════════════════════════════
// 2. QuranMushafContent
// ═══════════════════════════════════════════════════════
class QuranMushafContent extends StatelessWidget {
  final PageEntity page;
  final double availableWidth;
  final double availableHeight;
  final String Function(int surahNumber) getSurahName;

  const QuranMushafContent({
    super.key,
    required this.page,
    required this.availableWidth,
    required this.availableHeight,
    required this.getSurahName,
  });

  static const double _horizontalPaddingRatio = 0.06; // 6% يمين + يسار
  static const double _verticalPaddingRatio = 0.04;   // 4% فوق + تحت

  @override
  Widget build(BuildContext context) {
    final ayahs = page.ayahs;
    if (ayahs.isEmpty) return const SizedBox.expand();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final segments = _splitBySurah(ayahs);

        final horizontalPadding = width * _horizontalPaddingRatio;
        final verticalPadding = height * _verticalPaddingRatio;

        final fontSize = _calculateFontSize(
          segments: segments,
          width: width,
          height: height,
          horizontalPadding: horizontalPadding,
          verticalPadding: verticalPadding,
        );

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/page_frame.png',
                fit: BoxFit.fill,
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final segment in segments) ...[
                        if (segment.isNewSurah)
                          _SurahHeader(
                            surahName: getSurahName(segment.surahNumber),
                            fontSize: math.min(fontSize * 0.85, 22),
                            surahNumber: segment.surahNumber,
                          ),
                        RichText(
                          textAlign: TextAlign.justify,
                          textDirection: TextDirection.rtl,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: fontSize,
                              height: 1.8,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              // fontFamily: 'UthmanicHafs',
                            ),
                            children: _buildSpans(segment.ayahs, fontSize),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_Segment> _splitBySurah(List<AyahEntity> ayahs) {
    final segments = <_Segment>[];
    int? currentSurah;
    bool currentIsNew = false;
    List<AyahEntity> current = [];

    for (final ayah in ayahs) {
      if (currentSurah == null || ayah.surahNumber != currentSurah) {
        if (current.isNotEmpty) {
          segments.add(_Segment(
            surahNumber: currentSurah!,
            ayahs: current,
            isNewSurah: currentIsNew,
          ));
        }
        currentSurah = ayah.surahNumber;
        currentIsNew = ayah.ayahNumber == 1;
        current = [ayah];
      } else {
        current.add(ayah);
      }
    }

    if (current.isNotEmpty) {
      segments.add(_Segment(
        surahNumber: currentSurah!,
        ayahs: current,
        isNewSurah: currentIsNew,
      ));
    }

    return segments;
  }

  List<InlineSpan> _buildSpans(List<AyahEntity> ayahs, double fontSize) {
    final spans = <InlineSpan>[];
    const arabicNumbers = '٠١٢٣٤٥٦٧٨٩';

    String toArabic(int n) => n
        .toString()
        .split('')
        .map((d) => arabicNumbers[int.parse(d)])
        .join('');

    for (int i = 0; i < ayahs.length; i++) {
      final ayah = ayahs[i];
      spans.add(TextSpan(text: ayah.text));
      spans.add(TextSpan(
        text: ' \u06DD${toArabic(ayah.ayahNumber)} ',
        style: const TextStyle(
          color: Color(0xFFB8860B),
        ),
      ));
    }
    return spans;
  }

  double _calculateFontSize({
    required List<_Segment> segments,
    required double width,
    required double height,
    required double horizontalPadding,
    required double verticalPadding,
  }) {
    double fontSize = 24;

    final usableWidth = width - (horizontalPadding * 2);
    final usableHeight = height - (verticalPadding * 2);

    while (fontSize > 8) {
      double totalHeight = 0;

      for (final segment in segments) {
        // ارتفاع شريط اسم السورة
        if (segment.isNewSurah) {
          final headerFontSize = math.min(fontSize * 0.85, 22.0);
          totalHeight += (headerFontSize * 2.8) + (headerFontSize * 0.8);
        }

        // ارتفاع نص الآيات
        final painter = TextPainter(
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              height: 1.8,
              fontWeight: FontWeight.w500,
            ),
            children: _buildSpans(segment.ayahs, fontSize),
          ),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.justify,
        );

        painter.layout(minWidth: usableWidth, maxWidth: usableWidth);
        totalHeight += painter.height;
      }

      // هامش أمان 5%
      if (totalHeight <= usableHeight * 0.95) return fontSize;
      fontSize -= 0.5;
    }
    return 8;
  }
}

// ═══════════════════════════════════════════════════════
// 3. _SurahHeader (بصورة)
// ═══════════════════════════════════════════════════════
class _SurahHeader extends StatelessWidget {
  final String surahName;
  final double fontSize;
  final int surahNumber;

  const _SurahHeader({
    required this.surahName,
    required this.fontSize,
    required this.surahNumber,
  });

  @override
  Widget build(BuildContext context) {
    final headerHeight = fontSize * 2.8;

    // سورة التوبة لا تبدأ بالبسملة
    final bool showBasmala = surahNumber != 9;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: headerHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/name_surah2.png',
                fit: BoxFit.fill,
              ),

              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: fontSize * 1.5,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'سُورَةُ $surahName',
                      style: TextStyle(
                        fontSize: fontSize * 0.8,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3B2E10),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // البسملة في بداية السورة ما عدا التوبة
        if (showBasmala)
          Padding(
            padding: EdgeInsets.only(
              top: fontSize * 0.25,
              bottom: fontSize * 0.15,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: fontSize * 0.85,
                  height: 1.2,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
