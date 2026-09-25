import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';
import '../bloc/azkar_bloc.dart';
import '../bloc/azkar_event.dart';
import '../bloc/azkar_state.dart';
import '../widgets/azkar_category_card.dart';
import '../widgets/azkar_zikr_card.dart';

class AzkarView extends StatefulWidget {
  const AzkarView({super.key});

  @override
  State<AzkarView> createState() => _AzkarViewState();
}

class _AzkarViewState extends State<AzkarView> {
  final Map<int, Set<int>> _hiddenItemsByChapter = {};
  final Map<int, Map<int, int>> _remainingByChapter = {};
  final Map<int, List<int>> _historyByChapter = {};

  static const Color _primaryColor = Color(0xFF1B4332);
  static const Color _accentColor = Color(0xFFD4AF37);
  static const Color _bgColor = Color(0xFFF9F6F0);

  Set<int> _hidden(int chapterId) =>
      _hiddenItemsByChapter.putIfAbsent(chapterId, () => {});

  Map<int, int> _remaining(int chapterId) =>
      _remainingByChapter.putIfAbsent(chapterId, () => {});

  List<int> _history(int chapterId) =>
      _historyByChapter.putIfAbsent(chapterId, () => []);

  void _onItemTap(dynamic item, int chapterId) {
    setState(() {
      final id = item.id;
      final remaining = _remaining(chapterId);
      final hidden = _hidden(chapterId);
      final history = _history(chapterId);

      remaining[id] ??= item.count;
      remaining[id] = remaining[id]! - 1;
      history.add(id);

      if (remaining[id]! <= 0) {
        hidden.add(id);
      }
    });
  }

  void _undo(int chapterId) {
    final history = _history(chapterId);
    if (history.isEmpty) return;

    setState(() {
      final lastId = history.removeLast();
      _hidden(chapterId).remove(lastId);
      final remaining = _remaining(chapterId);
      if (remaining.containsKey(lastId)) {
        remaining[lastId] = remaining[lastId]! + 1;
      }
    });
  }

  void _onBackPressed(AzkarState state) {
    if (state is AzkarItemsLoaded) {
      _resetAzkarProgress();
      context.read<AzkarBloc>().add(const BackToChapters());
      return;
    }

    if (state is AzkarChaptersLoaded) {
      context.read<AzkarBloc>().add(const BackToCategories());
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.home,
          (route) => false,
    );
  }

  void _resetAzkarProgress() {
    _hiddenItemsByChapter.clear();
    _remainingByChapter.clear();
    _historyByChapter.clear();
    debugPrint('AZKAR PROGRESS RESET');
  }

  @override
  void initState() {
    super.initState();
    debugPrint('AZKAR VIEW CREATED');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarBloc, AzkarState>(
      builder: (context, state) {
        final currentChapterId =
        state is AzkarItemsLoaded ? state.chapterId : null;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _onBackPressed(state);
          },
          child: Scaffold(
            backgroundColor: _bgColor,
            appBar: AppBar(
              backgroundColor: _primaryColor,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'الأذكار',
                style: GoogleFonts.amiri(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: _accentColor,
                ),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24.r,
                ),
                onPressed: () => _onBackPressed(state),
              ),
              actions: [
                if (state is AzkarItemsLoaded &&
                    _history(state.chapterId).isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.undo, color: Colors.white, size: 24.r),
                    tooltip: 'تراجع',
                    onPressed: () => _undo(state.chapterId),
                  ),
              ],
            ),
            body: _buildBody(state, currentChapterId),
          ),
        );
      },
    );
  }

  Widget _buildBody(AzkarState state, int? currentChapterId) {
    if (state is AzkarLoading) {
      return Center(
        child: CircularProgressIndicator(color: _primaryColor),
      );
    }

    if (state is AzkarError) {
      return Center(
        child: Text(
          state.message,
          style: GoogleFonts.cairo(color: Colors.red, fontSize: 16.sp),
        ),
      );
    }

    if (state is AzkarCategoriesLoaded) {
      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final category = state.categories[index];
          return AzkarCategoryCard(
            title: category.name,
            icon: Icons.menu_book_rounded,
            onTap: () {
              context.read<AzkarBloc>().add(LoadAzkarChapters(category.id));
            },
          );
        },
      );
    }

    if (state is AzkarChaptersLoaded) {
      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: state.chapters.length,
        itemBuilder: (context, index) {
          final chapter = state.chapters[index];
          return AzkarCategoryCard(
            title: chapter.name,
            icon: Icons.bookmark_border_rounded,
            onTap: () {
              context.read<AzkarBloc>().add(LoadAzkarItems(chapter.id));
            },
          );
        },
      );
    }

    if (state is AzkarItemsLoaded) {
      final chapterId = state.chapterId;
      final hidden = _hidden(chapterId);
      final remainingMap = _remaining(chapterId);

      final visibleItems = state.items
          .where((item) => !hidden.contains(item.id))
          .toList();

      if (visibleItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80.r,
                color: _primaryColor,
              ),
              SizedBox(height: 16.h),
              Text(
                'تم الانتهاء من الأذكار',
                style: GoogleFonts.amiri(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'تقبل الله منا ومنكم صالح الأعمال',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: visibleItems.length,
        itemBuilder: (context, index) {
          final item = visibleItems[index];
          final remaining = remainingMap[item.id] ?? item.count;
          final total = item.count;
          final progress = total > 0 ? (total - remaining) / total : 0.0;

          return AzkarZikrCard(
            text: item.text,
            count: item.count,
            remaining: remaining,
            progress: progress,
            onTap: () => _onItemTap(item, chapterId),
          );
        },
      );
    }

    return const SizedBox();
  }
}