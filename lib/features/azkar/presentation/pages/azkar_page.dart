// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart'; // أضف هذه المكتبة
// import 'package:google_fonts/google_fonts.dart';
//
// import '../../../../core/router/app_router.dart';
// import '../../../../injection_container.dart';
// import '../bloc/azkar_bloc.dart';
// import '../bloc/azkar_event.dart';
// import '../bloc/azkar_state.dart';
//
// class AzkarPage extends StatelessWidget {
//   const AzkarPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // لف الصفحة بالكامل بـ ScreenUtilInit
//     return ScreenUtilInit(
//       designSize: const Size(375, 812), // حجم التصميم المرجعي (iPhone X)
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         return BlocProvider(
//           create: (_) => sl<AzkarBloc>()..add(const LoadAzkarCategories()),
//           child: const _AzkarView(),
//         );
//       },
//     );
//   }
// }
//
// class _AzkarView extends StatefulWidget {
//   const _AzkarView();
//
//   @override
//   State<_AzkarView> createState() => _AzkarViewState();
// }
//
// class _AzkarViewState extends State<_AzkarView> {
//   final Map<int, Set<int>> _hiddenItemsByChapter = {};
//   final Map<int, Map<int, int>> _remainingByChapter = {};
//   final Map<int, List<int>> _historyByChapter = {};
//
//   final Color _primaryColor = const Color(0xFF1B4332);
//   final Color _accentColor = const Color(0xFFD4AF37);
//   final Color _bgColor = const Color(0xFFF9F6F0);
//   final Color _cardColor = const Color(0xFFFFFDF9);
//
//   Set<int> _hidden(int chapterId) =>
//       _hiddenItemsByChapter.putIfAbsent(chapterId, () => {});
//
//   Map<int, int> _remaining(int chapterId) =>
//       _remainingByChapter.putIfAbsent(chapterId, () => {});
//
//   List<int> _history(int chapterId) =>
//       _historyByChapter.putIfAbsent(chapterId, () => []);
//
//   void _onItemTap(dynamic item, int chapterId) {
//     setState(() {
//       final id = item.id;
//       final remaining = _remaining(chapterId);
//       final hidden = _hidden(chapterId);
//       final history = _history(chapterId);
//
//       remaining[id] ??= item.count;
//       remaining[id] = remaining[id]! - 1;
//       history.add(id);
//
//       if (remaining[id]! <= 0) {
//         hidden.add(id);
//       }
//     });
//   }
//
//   void _undo(int chapterId) {
//     final history = _history(chapterId);
//     if (history.isEmpty) return;
//
//     setState(() {
//       final lastId = history.removeLast();
//       _hidden(chapterId).remove(lastId);
//       final remaining = _remaining(chapterId);
//       if (remaining.containsKey(lastId)) {
//         remaining[lastId] = remaining[lastId]! + 1;
//       }
//     });
//   }
//
//   void _onBackPressed(AzkarState state) {
//     if (state is AzkarItemsLoaded) {
//       _resetAzkarProgress();
//       context.read<AzkarBloc>().add(const BackToChapters());
//       return;
//     }
//
//     if (state is AzkarChaptersLoaded) {
//       context.read<AzkarBloc>().add(const BackToCategories());
//       return;
//     }
//
//     Navigator.pushNamedAndRemoveUntil(
//       context,
//       AppRouter.home,
//           (route) => false,
//     );
//   }
//
//   void _resetAzkarProgress() {
//     _hiddenItemsByChapter.clear();
//     _remainingByChapter.clear();
//     _historyByChapter.clear();
//     debugPrint('🧹 AZKAR PROGRESS RESET');
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     debugPrint('🟢 AZKAR VIEW CREATED');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AzkarBloc, AzkarState>(
//       builder: (context, state) {
//         final currentChapterId =
//         state is AzkarItemsLoaded ? state.chapterId : null;
//
//         return PopScope(
//           canPop: false,
//           onPopInvokedWithResult: (didPop, result) {
//             if (didPop) return;
//             _onBackPressed(state);
//           },
//           child: Scaffold(
//             backgroundColor: _bgColor,
//             appBar: AppBar(
//               backgroundColor: _primaryColor,
//               elevation: 0,
//               centerTitle: true,
//               title: Text(
//                 'الأذكار',
//                 style: GoogleFonts.amiri(
//                   fontSize: 28.sp,
//                   fontWeight: FontWeight.bold,
//                   color: _accentColor,
//                 ),
//               ),
//               leading: IconButton(
//                 icon: Icon(
//                   Icons.arrow_back,
//                   color: Colors.white,
//                   size: 24.r,
//                 ),
//                 onPressed: () => _onBackPressed(state),
//               ),
//               actions: [
//                 if (state is AzkarItemsLoaded &&
//                     _history(state.chapterId).isNotEmpty)
//                   IconButton(
//                     icon: Icon(Icons.undo, color: Colors.white, size: 24.r),
//                     tooltip: 'تراجع',
//                     onPressed: () => _undo(state.chapterId),
//                   ),
//               ],
//             ),
//             body: _buildBody(state, currentChapterId),
//           ),
//         );
//       },
//     );
//   }
//
//
//   Widget _buildBody(AzkarState state, int? currentChapterId) {
//     if (state is AzkarLoading) {
//       return Center(
//         child: CircularProgressIndicator(color: _primaryColor),
//       );
//     }
//
//     if (state is AzkarError) {
//       return Center(
//         child: Text(
//           state.message,
//           style: GoogleFonts.cairo(color: Colors.red, fontSize: 16.sp),
//         ),
//       );
//     }
//
//     if (state is AzkarCategoriesLoaded) {
//       return ListView.builder(
//         padding: EdgeInsets.all(16.w), // استخدام w للـ padding
//         itemCount: state.categories.length,
//         itemBuilder: (context, index) {
//           final category = state.categories[index];
//           return _buildCategoryCard(
//             title: category.name,
//             icon: Icons.menu_book_rounded,
//             onTap: () {
//               context.read<AzkarBloc>().add(LoadAzkarChapters(category.id));
//             },
//           );
//         },
//       );
//     }
//
//     if (state is AzkarChaptersLoaded) {
//       return ListView.builder(
//         padding: EdgeInsets.all(16.w),
//         itemCount: state.chapters.length,
//         itemBuilder: (context, index) {
//           final chapter = state.chapters[index];
//           return _buildCategoryCard(
//             title: chapter.name,
//             icon: Icons.bookmark_border_rounded,
//             onTap: () {
//               context.read<AzkarBloc>().add(LoadAzkarItems(chapter.id));
//             },
//           );
//         },
//       );
//     }
//
//     if (state is AzkarItemsLoaded) {
//       final chapterId = state.chapterId;
//       final hidden = _hidden(chapterId);
//       final remainingMap = _remaining(chapterId);
//
//       final visibleItems = state.items
//           .where((item) => !hidden.contains(item.id))
//           .toList();
//
//       if (visibleItems.isEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.check_circle_outline,
//                 size: 80.r,
//                 color: _primaryColor,
//               ),
//               SizedBox(height: 16.h),
//               Text(
//                 'تم الانتهاء من الأذكار',
//                 style: GoogleFonts.amiri(
//                   fontSize: 24.sp,
//                   fontWeight: FontWeight.bold,
//                   color: _primaryColor,
//                 ),
//               ),
//               SizedBox(height: 8.h),
//               Text(
//                 'تقبل الله منا ومنكم صالح الأعمال',
//                 style: GoogleFonts.cairo(
//                   fontSize: 16.sp,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         );
//       }
//
//       return ListView.builder(
//         padding: EdgeInsets.all(16.w),
//         itemCount: visibleItems.length,
//         itemBuilder: (context, index) {
//           final item = visibleItems[index];
//           final remaining = remainingMap[item.id] ?? item.count;
//           final total = item.count;
//           final progress = total > 0 ? (total - remaining) / total : 0.0;
//
//           return _buildZikrCard(item, remaining, progress, chapterId);
//         },
//       );
//     }
//
//     return const SizedBox();
//   }
//
//   Widget _buildCategoryCard({
//     required String title,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       decoration: BoxDecoration(
//         color: _cardColor,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10.r,
//             offset: Offset(0, 4.h),
//           ),
//         ],
//         border: Border.all(color: _accentColor.withOpacity(0.3)),
//       ),
//       child: ListTile(
//         contentPadding:
//         EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
//         leading: Container(
//           padding: EdgeInsets.all(10.r),
//           decoration: BoxDecoration(
//             color: _primaryColor.withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: _primaryColor, size: 24.r),
//         ),
//         title: Text(
//           title,
//           textDirection: TextDirection.rtl,
//           style: GoogleFonts.amiri(
//             fontSize: 20.sp,
//             fontWeight: FontWeight.bold,
//             color: _primaryColor,
//           ),
//         ),
//         trailing:
//         Icon(Icons.arrow_forward_ios, size: 16.r, color: _accentColor),
//         onTap: onTap,
//       ),
//     );
//   }
//
//   Widget _buildZikrCard(
//       dynamic item, int remaining, double progress, int chapterId) {
//     return GestureDetector(
//       onTap: () => _onItemTap(item, chapterId),
//       child: Container(
//         margin: EdgeInsets.only(bottom: 20.h),
//         decoration: BoxDecoration(
//           color: _cardColor,
//           borderRadius: BorderRadius.circular(24.r),
//           boxShadow: [
//             BoxShadow(
//               color: _primaryColor.withOpacity(0.08),
//               blurRadius: 15.r,
//               offset: Offset(0, 5.h),
//             ),
//           ],
//           border: Border.all(color: _accentColor.withOpacity(0.4), width: 1.5.w),
//         ),
//         child: Column(
//           children: [
//             // زخرفة علوية
//             Container(
//               height: 6.h,
//               decoration: BoxDecoration(
//                 color: _primaryColor,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(24.r),
//                   topRight: Radius.circular(24.r),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(24.r),
//               child: Column(
//                 children: [
//                   Text(
//                     item.text,
//                     textDirection: TextDirection.rtl,
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.amiri(
//                       fontSize: 22.sp,
//                       height: 2.2,
//                       color: const Color(0xFF2C2C2C),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   SizedBox(height: 20.h),
//                   // فاصل مزخرف
//                   Row(
//                     children: [
//                       Expanded(
//                           child: Divider(color: _accentColor.withOpacity(0.5))),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 8.w),
//                         child: Icon(Icons.star,
//                             size: 16.r, color: _accentColor),
//                       ),
//                       Expanded(
//                           child: Divider(color: _accentColor.withOpacity(0.5))),
//                     ],
//                   ),
//                   SizedBox(height: 16.h),
//                   if (item.count > 1)
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // شريط تقدم دائري
//                         SizedBox(
//                           width: 50.r,
//                           height: 50.r,
//                           child: Stack(
//                             fit: StackFit.expand,
//                             children: [
//                               CircularProgressIndicator(
//                                 value: progress,
//                                 backgroundColor: Colors.grey[200],
//                                 color: _primaryColor,
//                                 strokeWidth: 5.w,
//                               ),
//                               Center(
//                                 child: Text(
//                                   '$remaining',
//                                   style: GoogleFonts.cairo(
//                                     fontSize: 16.sp,
//                                     fontWeight: FontWeight.bold,
//                                     color: _primaryColor,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(width: 16.w),
//                         Text(
//                           'المتبقي',
//                           style: GoogleFonts.cairo(
//                             fontSize: 14.sp,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     )
//                   else
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: 20.w, vertical: 8.h),
//                       decoration: BoxDecoration(
//                         color: _primaryColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20.r),
//                         border: Border.all(
//                             color: _primaryColor.withOpacity(0.3)),
//                       ),
//                       child: Text(
//                         'اضغط للقراءة',
//                         style: GoogleFonts.cairo(
//                           color: _primaryColor,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14.sp,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../injection_container.dart';
import '../bloc/azkar_bloc.dart';
import '../bloc/azkar_event.dart';
import 'azkar_view.dart';

class AzkarPage extends StatelessWidget {
  const AzkarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider(
          create: (_) => sl<AzkarBloc>()..add(const LoadAzkarCategories()),
          child: const AzkarView(),
        );
      },
    );
  }
}