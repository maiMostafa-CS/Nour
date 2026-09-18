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
    final double offsetY = _currentPage <= 2 ? -40 : 10.0;

    return Transform.translate(
      offset: Offset(0, offsetY),
      child: Stack(
        children: [
          // ======================================================
          // المصحف
          // ======================================================

          PageviewQuran(
            pageBackgroundColor: const Color(0xFFFCF5D7),
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            sp: .9.w,
            h: 1.h,

            verseBackgroundColor: _verseBackgroundColor,

            onTap: (surahNumber, verseNumber) {
              debugPrint(
                '📖 AYAH TAP: $surahNumber:$verseNumber',
              );

              if (!mounted) return;

              setState(() {
                _selectedSurahNumber = surahNumber;
                _selectedVerseNumber = verseNumber;
              });

              _triggerAyahFlash();

              widget.onAyahTap?.call(
                surahNumber: surahNumber,
                verseNumber: verseNumber,
              );
            },

            // ====================================================
            // تغيير الصفحة
            // ====================================================

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
                child: _buildAyahActions()
                // _buildAyahActions(),
                ),
        ],
      ),
    );
  }

  Widget _buildAyahActions() {
    if (_selectedSurahNumber == null ||
        _selectedVerseNumber == null) {
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

            context.read<QuranIndexBloc>().add(
              PlayAyah(
                reciterIdentifier:
                selectedReciter.identifier,
                globalAyahNumber: globalAyahNumber,
              ),
            );
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
  void _showTafsir(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFCF5D7),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تفسير ${getSurahNameArabic(_selectedSurahNumber!)}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'الآية ${_selectedVerseNumber!}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 20.h),
                const Text(
                  'سيتم تحميل التفسير هنا.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
