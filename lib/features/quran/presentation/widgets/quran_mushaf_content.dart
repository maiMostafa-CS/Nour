import 'package:flutter/material.dart';

import '../../domain/entities/surah_entity.dart';

class QuranMushafContent extends StatelessWidget {
  final PageEntity page;
  final double availableWidth;
  final double availableHeight;

  const QuranMushafContent({
    super.key,
    required this.page,
    required this.availableWidth,
    required this.availableHeight,
  });

  @override
  Widget build(BuildContext context) {
    final ayahs = page.ayahs;

    if (ayahs.isEmpty) {
      return const SizedBox.expand();
    }
    String _arabicNumber(int number) {
      const arabicNumbers = '٠١٢٣٤٥٦٧٨٩';
      return number
          .toString()
          .split('')
          .map((digit) => arabicNumbers[int.parse(digit)])
          .join('');  // ← مهم: فاضي
    }

    final text = ayahs
        .map((e) => '${e.text} ۝${_arabicNumber(e.ayahNumber)}')
        .join(' ');
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final fontSize = _calculateFontSize(
          text: text,
          width: width,
          height: height,
        );

        return SizedBox(
          width: width,
          height: height,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              text,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              softWrap: true,
              style: TextStyle(
                fontSize: fontSize,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateFontSize({
    required String text,
    required double width,
    required double height,
  }) {
    double fontSize = 24;

    final maxHeight = height - 30;

    while (fontSize > 12) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.justify,
        maxLines: null,
      );

      painter.layout(
        minWidth: width,
        maxWidth: width,
      );

      if (painter.height <= maxHeight) {
        return fontSize;
      }

      fontSize -= 0.25;
    }

    return 12;
  }
}