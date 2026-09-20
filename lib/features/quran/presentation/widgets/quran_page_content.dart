import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/features/quran/presentation/widgets/reciter_selection/%20reciter_selection_sheet.dart';
import 'package:qcf_quran/qcf_quran.dart';

import '../../../../core/data/quran/quran_helpers.dart';
import '../bloc/quran_bloc.dart';
import '../bloc/quran_event.dart';
import '../bloc/quran_state.dart';
import 'ayah_action_button.dart';
import 'build_ayah_actions.dart';
import 'no_internet_listener.dart';

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

  final void Function({
  required int surahNumber,
  required int verseNumber,
  })? onAyahTap;

  const QuranPageContent({
    super.key,
    required this.pageNumber,
    this.controller,
    this.onPageInfoLoaded,
    this.onAyahTap,
  });

  @override
  State<QuranPageContent> createState() => _QuranPageContentState();
}

class _QuranPageContentState extends State<QuranPageContent>
    with SingleTickerProviderStateMixin {
  late final PageController _controller;

  int _currentPage = 1;
  String _currentSurahName = '';
  int? _currentJuz;

  // ============================================================
  // الآية المحددة
  // ============================================================

  int? _selectedSurahNumber;
  int? _selectedVerseNumber;

  // ============================================================
  // آخر عملية تحتاج إنترنت (لزر "إعادة المحاولة")
  // ============================================================

  VoidCallback? _lastRetryAction;

  // ============================================================
  // فلاش الآية
  // ============================================================

  AnimationController? _flashController;
  Animation<double>? _flashOpacity;

  @override
  void initState() {
    super.initState();

    _currentPage = widget.pageNumber;

    _controller = PageController(
      initialPage: widget.pageNumber - 1,
    );

    // ==========================================================
    // أنيميشن الفلاش
    // ==========================================================

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _flashController = controller;

    _flashOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween:
        Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 70,
      ),
    ]).animate(controller);

    controller.addListener(_onFlashTick);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportPageInfo(widget.pageNumber);
    });
  }

  void _onFlashTick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _flashController?.removeListener(_onFlashTick);
    _flashController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _triggerAyahFlash() {
    _flashController?.forward(from: 0);
  }

  Color? _verseBackgroundColor(int surahNumber, int verseNumber) {
    if (_selectedSurahNumber != surahNumber ||
        _selectedVerseNumber != verseNumber) {
      return null;
    }

    final double opacity = _flashOpacity?.value ?? 0.0;

    if (opacity <= 0.01) {
      return const Color(0x33FFD54F);
    }

    return Color.fromRGBO(255, 213, 79, opacity * 0.7);
  }

  @override
  Widget build(BuildContext context) {
    final double offsetY = _currentPage <= 2 ? -50 : -8.0;

    return NoInternetListener(
      onRetry: () => _lastRetryAction?.call(),
      child: Transform.translate(
        offset: Offset(0, offsetY),
        child: Stack(
          children: [
            // ====================================================
            // المصحف
            // ====================================================

            PageviewQuran(
              pageBackgroundColor: const Color(0xFFFCF5D7),
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              sp: .9.w,
              h: 1.h,

              verseBackgroundColor: _verseBackgroundColor,

              onTap: (surahNumber, verseNumber) {
                debugPrint(
                  '📖 AYAH TAP → '
                      'surah=$surahNumber, '
                      'ayah=$verseNumber',
                );

                if (!mounted) return;

                setState(() {
                  _selectedSurahNumber = surahNumber;
                  _selectedVerseNumber = verseNumber;
                });

                debugPrint(
                  '📌 SELECTED → '
                      'surah=$_selectedSurahNumber, '
                      'ayah=$_selectedVerseNumber',
                );

                _triggerAyahFlash();

                widget.onAyahTap?.call(
                  surahNumber: surahNumber,
                  verseNumber: verseNumber,
                );
              },

              // ==================================================
              // تغيير الصفحة
              // ==================================================

              onPageChanged: (pageNumber) {
                _reportPageInfo(pageNumber);

                if (!mounted) return;

                setState(() {
                  _selectedSurahNumber = null;
                  _selectedVerseNumber = null;
                });

                _flashController?.reset();
              },
            ),

            if (_selectedSurahNumber != null && _selectedVerseNumber != null)
              Positioned(
                left: 12.w,
                right: 12.w,
                bottom: 18.h,
                child: _buildAyahActions(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAyahActions() {
    if (_selectedSurahNumber == null || _selectedVerseNumber == null) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<QuranIndexBloc, QuranIndexState>(
      builder: (context, state) {
        QuranIndexLoaded? loadedState;

        if (state is QuranIndexLoaded) {
          loadedState = state;
        }

        final isPlaying = loadedState?.isPlaying ?? false;
        final isPaused = loadedState?.isPaused ?? false;
        final selectedReciter = loadedState?.selectedReciter;

        return AyahActions(
          surahNumber: _selectedSurahNumber!,
          verseNumber: _selectedVerseNumber!,
          surahName: getSurahNameArabic(
            _selectedSurahNumber!,
          ),

          isPlaying: isPlaying,
          isPaused: isPaused,

          reciterName: selectedReciter?.name,

          // ======================================================
          // تشغيل الآية
          // ======================================================

          onListen: () {
            debugPrint('🔵 onListen triggered');
            debugPrint('   selectedReciter = $selectedReciter');
            debugPrint('   surahNumber = $_selectedSurahNumber');
            debugPrint('   verseNumber = $_selectedVerseNumber');

            if (selectedReciter == null) {
              debugPrint('⚠️ selectedReciter is null → show reciter selection');
              _showReciterSelection(context);
              return;
            }

            final globalAyahNumber = getGlobalAyahNumber(
              _selectedSurahNumber!,
              _selectedVerseNumber!,
            );

            final bloc = context.read<QuranIndexBloc>();

            final playEvent = PlayAyah(
              reciterIdentifier: selectedReciter.identifier,
              globalAyahNumber: globalAyahNumber,
            );

            // لو مفيش نت، زر "إعادة المحاولة" يعيد التشغيل
            _lastRetryAction = () => bloc.add(playEvent);

            bloc.add(playEvent);
          },

          // ======================================================
          // Pause
          // ======================================================

          onPause: () {
            context.read<QuranIndexBloc>().add(
              const PauseAyah(),
            );
          },

          // ======================================================
          // Resume
          // ======================================================

          onResume: () {
            context.read<QuranIndexBloc>().add(
              const ResumeAyah(),
            );
          },

          // ======================================================
          // اختيار القارئ
          // ======================================================

          onReciter: () {
            _showReciterSelection(context);
          },

          // ======================================================
          // التفسير
          // ======================================================

          onTafsir: () {
            _showTafsir(context);
          },

          // ======================================================
          // إغلاق
          // ======================================================

          onClose: () {
            context.read<QuranIndexBloc>().add(
              const StopAyah(),
            );

            if (!mounted) return;

            setState(() {
              _selectedSurahNumber = null;
              _selectedVerseNumber = null;
            });

            _flashController?.reset();
          },
        );
      },
    );
  }

  // ============================================================
  // بيانات الصفحة
  // ============================================================

  void _reportPageInfo(int pageNumber) {
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

    final int juz = getJuzNumber(surahNumber, verseNumber);

    final int? hizbNumber = getHizbNumber(surahNumber, verseNumber);

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
      hizb: hizbNumber,
      rub: null,
    );
  }

  void _showReciterSelection(BuildContext context) {
    final state = context.read<QuranIndexBloc>().state;

    if (state is! QuranIndexLoaded) {
      return;
    }

    if (state.reciters.isEmpty) {
      context.read<QuranIndexBloc>().add(
        const LoadReciters(),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return ReciterSelectionSheet(
          reciters: state.reciters,
          selectedReciter: state.selectedReciter,
          onSelected: (reciter) {
            context.read<QuranIndexBloc>().add(
              SelectReciter(
                reciter.identifier,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showTafsir(BuildContext context) async {
    final surahNumber = _selectedSurahNumber;
    final verseNumber = _selectedVerseNumber;

    if (surahNumber == null || verseNumber == null) {
      return;
    }

    final bloc = context.read<QuranIndexBloc>();

    // فحص الإنترنت قبل فتح الـ BottomSheet
    final online = await _hasInternet();

    if (!context.mounted) return;

    if (!online) {
      showNoInternetDialog(
        context,
        onRetry: () => _showTafsir(context),
      );
      return;
    }

    _lastRetryAction = () => bloc.add(
      LoadAyahTafsir(
        surahNumber: surahNumber,
        ayahNumber: verseNumber,
      ),
    );

    bloc.add(
      LoadAyahTafsir(
        surahNumber: surahNumber,
        ayahNumber: verseNumber,
      ),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFCF5D7),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return BlocBuilder<QuranIndexBloc, QuranIndexState>(
                builder: (context, state) {
                  if (state is! QuranIndexLoaded) {
                    return SizedBox(
                      height: 300.h,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final books = state.tafsirBooks;
                  final selectedBook = state.selectedTafsirBook;
                  final tafsir = state.ayahTafsir;
                  final isLoading = state.isTafsirLoading;

                  return SafeArea(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ==================================================
                            // Header
                            // ==================================================

                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'تفسير ${getSurahNameArabic(surahNumber)}',
                                    style: TextStyle(
                                      fontSize: 19.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),

                            SizedBox(height: 4.h),

                            Text(
                              'الآية $verseNumber',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black54,
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // ==================================================
                            // Loading books
                            // ==================================================

                            if (isLoading && books.isEmpty)
                              const Expanded(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )

                            // ==================================================
                            // No books
                            // ==================================================

                            else if (books.isEmpty)
                              Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.menu_book_outlined,
                                        size: 48.sp,
                                        color: Colors.black38,
                                      ),
                                      SizedBox(height: 12.h),
                                      Text(
                                        'لا توجد كتب تفسير متاحة',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )

                            // ==================================================
                            // Content
                            // ==================================================

                            else ...[
                                // اختيار كتاب التفسير
                                Text(
                                  'كتاب التفسير',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 8.h),

                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(14.r),
                                    border: Border.all(
                                      color: Colors.black12,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: selectedBook?.id,
                                      isExpanded: true,
                                      borderRadius: BorderRadius.circular(14.r),
                                      items: books.map((book) {
                                        return DropdownMenuItem<int>(
                                          value: book.id,
                                          child: Text(
                                            book.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (bookId) {
                                        if (bookId == null) return;

                                        bloc.add(
                                          SelectTafsirBook(bookId),
                                        );

                                        bloc.add(
                                          LoadAyahTafsir(
                                            surahNumber: surahNumber,
                                            ayahNumber: verseNumber,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20.h),

                                // اسم الكتاب الحالي
                                if (selectedBook != null)
                                  Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.45),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.menu_book,
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            selectedBook.name,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                SizedBox(height: 16.h),

                                // التفسير
                                Expanded(
                                  child: isLoading
                                      ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                      : tafsir == null
                                      ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 42.sp,
                                          color: Colors.black38,
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                          'لا يوجد تفسير لهذه الآية',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                      : SingleChildScrollView(
                                    physics:
                                    const BouncingScrollPhysics(),
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withOpacity(0.55),
                                        borderRadius:
                                        BorderRadius.circular(
                                          16.r,
                                        ),
                                      ),
                                      child: Directionality(
                                        textDirection:
                                        TextDirection.rtl,
                                        child: Text(
                                          tafsir.text,
                                          textAlign:
                                          TextAlign.justify,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            height: 1.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('api.quran.com')
          .timeout(const Duration(seconds: 5));

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }
}