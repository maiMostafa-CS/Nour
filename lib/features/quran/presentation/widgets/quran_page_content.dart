import 'package:flutter/material.dart';
import 'package:islamic_app/features/quran/presentation/widgets/quran_mushaf_content.dart';

import '../../../../injection_container.dart';
import '../../domain/entities/surah_entity.dart';
import '../../domain/usecases/get_page.dart';
import 'get_surah_name.dart';

class QuranPageContent extends StatefulWidget {
  final int pageNumber;

  final void Function({
  required String surahName,
  required int? juz,
  required int? hizb,
  int? rub,
  })? onPageInfoLoaded;

  const QuranPageContent({
    super.key,
    required this.pageNumber,
    this.onPageInfoLoaded,
  });

  @override
  State<QuranPageContent> createState() => _QuranPageContentState();
}

class _QuranPageContentState extends State<QuranPageContent> {
  late Future<PageEntity> _pageFuture;

  int? _reportedPage;

  @override
  void initState() {
    super.initState();

    _loadPage();
  }

  @override
  void didUpdateWidget(
      covariant QuranPageContent oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pageNumber != widget.pageNumber) {
      _reportedPage = null;
      _loadPage();
    }
  }

  void _loadPage() {
    final getPage = sl<GetPage>();

    _pageFuture = getPage(widget.pageNumber);
  }

  void _reportPageInfo(PageEntity page) {
    if (_reportedPage == widget.pageNumber) {
      return;
    }

    if (page.ayahs.isEmpty) {
      return;
    }

    final firstAyah = page.ayahs.first;

    final surahName = getSurahName(
      firstAyah.surahNumber,
    );

    _reportedPage = widget.pageNumber;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      widget.onPageInfoLoaded?.call(
        surahName: surahName,
        juz: firstAyah.juz,
        hizb: firstAyah.hizb,
        rub: firstAyah.rub,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PageEntity>(
      future: _pageFuture,
      builder: (context, snapshot) {
        // ======================================================
        // Loading
        // ======================================================

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.expand(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ======================================================
        // Error
        // ======================================================

        if (snapshot.hasError) {
          return SizedBox.expand(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'حدث خطأ في تحميل الصفحة:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final page = snapshot.data;

        // ======================================================
        // لا توجد بيانات
        // ======================================================

        if (page == null || page.ayahs.isEmpty) {
          return const SizedBox.expand(
            child: Center(
              child: Text(
                'لا توجد آيات في هذه الصفحة',
              ),
            ),
          );
        }

        // ======================================================
        // معلومات الصفحة
        // ======================================================

        _reportPageInfo(page);

        // ======================================================
        // صفحة المصحف
        // ======================================================

        return Directionality(
          textDirection: TextDirection.rtl,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    8,
                    12,
                    8,
                  ),
                  child: QuranMushafContent(
                    page: page,
                    availableWidth: constraints.maxWidth - 24,
                    availableHeight: constraints.maxHeight - 16,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}