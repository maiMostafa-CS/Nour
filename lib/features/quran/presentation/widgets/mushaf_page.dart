import 'package:flutter/material.dart';
import 'package:islamic_app/features/quran/presentation/widgets/quran_page_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/quran_bookmark_service.dart';
import '../pages/quran_search_page.dart';

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
  bool _isPageSaved = false;
  late final PageController _controller;

  late int _currentPage;

  String _currentSurahName = 'المصحف الشريف';

  int _currentJuz = 1;
  int _currentHizb = 1;

  Future<void> _toggleBookmark() async {
    final int? savedPage =
    await QuranBookmarkService.getSavedPage();

    if (savedPage == _currentPage) {
      await QuranBookmarkService.removeSavedPage();

      if (!mounted) return;

      setState(() {
        _isPageSaved = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إلغاء حفظ الصفحة',
            textAlign: TextAlign.center,
          ),
        ),
      );

      return;
    }

    final bool saved =
    await QuranBookmarkService.savePage(_currentPage);

    if (!saved) return;

    if (!mounted) return;

    setState(() {
      _isPageSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم حفظ الصفحة $_currentPage ✓',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

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
    required int pageNumber,
    required String surahName,
    required int? juz,
    required int? hizb,
    int? rub,
  }) {
    if (!mounted) return;

    setState(() {
      _currentPage = pageNumber;
      _currentSurahName = surahName;
      _currentJuz =juz??0 ;
      _currentHizb = hizb??0;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF5D7),
      appBar: QuranAppBar(
        surahName: _currentSurahName,
        currentJuz: 'الجزء $_currentJuz',
        isPageSaved: _isPageSaved,
        onBookmarkPressed: _toggleBookmark,
        onSearchPressed: () async {
          final int? pageNumber = await Navigator.push<int>(
            context,
            MaterialPageRoute(
              builder: (_) => const QuranSearchPage(),
            ),
          );

          if (pageNumber != null && mounted) {
            _controller.jumpToPage(pageNumber - 1);
          }
        },
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
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
            Container(
              margin: EdgeInsets.only(right: 10),
              height: 32,
              width: 180,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5C8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    ' رقم الصفحه  $_currentPage',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5A2B),
                    ),
                  ),

                  Container(
                    height: 16,
                    width: 1,
                    color: const Color(0xFF8B5A2B).withOpacity(0.3),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  Text(
                    'الحزب  ${_currentHizb ?? ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5A2B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class QuranAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String surahName;
  final String? currentJuz;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onBookmarkPressed;
  final bool isPageSaved;

  const QuranAppBar({
    Key? key,
    required this.surahName,
    this.currentJuz,
    this.onBackPressed,
    this.onSearchPressed,
    this.onBookmarkPressed,
    this.isPageSaved = false,

  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: preferredSize.height + statusBarHeight,
        color: const Color(0xFFFCF5D7),
        padding: EdgeInsets.only(
          top: statusBarHeight,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black87),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF8B5A2B), width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    surahName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5A2B),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, size: 20,
                    color: Color(0xFF8B5A2B),
                  ),
                  onPressed: onSearchPressed,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Color(0xFF8B5A2B),
                        width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    currentJuz??"" ,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isPageSaved
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    size: 22,
                    color: const Color(0xFF8B5A2B),
                  ),
                  tooltip: isPageSaved
                      ? 'الصفحة محفوظة'
                      : 'حفظ الصفحة',
                  onPressed: onBookmarkPressed,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}