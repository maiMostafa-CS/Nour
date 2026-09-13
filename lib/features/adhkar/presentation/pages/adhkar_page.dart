// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../injection_container.dart';
// import '../bloc/adhkar_bloc.dart';
//
// class AdhkarPage extends StatelessWidget {
//   const AdhkarPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => sl<AdhkarBloc>()..add(const LoadAdhkar()),
//       child: Scaffold(
//         appBar: AppBar(title: const Text('الأذكار')),
//         body: BlocBuilder<AdhkarBloc, AdhkarState>(
//           builder: (context, state) {
//             if (state is AdhkarLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (state is AdhkarError) return Center(child: Text(state.message));
//             if (state is AdhkarLoaded) {
//               print('🎨 Screen: AdhkarLoaded');
//               print('📿 عدد العناصر: ${state.items.length}');
//
//               return ListView.builder(
//                 padding: const EdgeInsets.all(12),
//                 itemCount: state.items.length,
//                 itemBuilder: (_, index) {
//                   final item = state.items[index];
//
//                   print(
//                     '🎨 عرض الذكر $index: ${item.text}',
//                   );
//
//                   return Card(
//                     child: ListTile(
//                       title: Text(
//                         item.text,
//                         textDirection: TextDirection.rtl,
//                         textAlign: TextAlign.right,
//                       ),
//                       subtitle: Text(
//                         item.category,
//                         textDirection: TextDirection.rtl,
//                       ),
//                       trailing: CircleAvatar(
//                         child: Text('${item.count}'),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }            return const SizedBox.shrink();
//           },
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdhkarPage extends StatelessWidget {
  const AdhkarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      const AdhkarCategory(
        title: 'أذكار الصباح',
        icon: '☀️',
      ),
      const AdhkarCategory(
        title: 'أذكار المساء',
        icon: '🌙',
      ),
      const AdhkarCategory(
        title: 'أذكار بعد الصلاة',
        icon: '🕌',
      ),
      const AdhkarCategory(
        title: 'أذكار النوم',
        icon: '🌙',
      ),
      const AdhkarCategory(
        title: 'أذكار الاستيقاظ',
        icon: '⏰',
      ),
      const AdhkarCategory(
        title: 'أذكار المسجد',
        icon: '🕌',
      ),
      const AdhkarCategory(
        title: 'أذكار الطعام',
        icon: '🍴',
      ),
      const AdhkarCategory(
        title: 'حصن المسلم',
        icon: '📖',
      ),
      const AdhkarCategory(
        title: 'أذكار دخول المنزل',
        icon: '🚪',
      ),
      const AdhkarCategory(
        title: 'أذكار الخروج من المنزل',
        icon: '🚶',
      ),
      const AdhkarCategory(
        title: 'أذكار دخول الخلاء',
        icon: '🚻',
      ),
      const AdhkarCategory(
        title: 'أذكار الخروج من الخلاء',
        icon: '🛁',
      ),
      const AdhkarCategory(
        title: 'أذكار اللباس',
        icon: '👕',
      ),
      const AdhkarCategory(
        title: 'أذكار السفر',
        icon: '🚗',
      ),
      const AdhkarCategory(
        title: 'أذكار المطر',
        icon: '🌧️',
      ),
      const AdhkarCategory(
        title: 'أذكار الرياح والرعد',
        icon: '🌩️',
      ),
      const AdhkarCategory(
        title: 'أذكار متنوعة',
        icon: '🤲',
      ),
      const AdhkarCategory(
        title: 'أدعية من القرآن',
        icon: '📖',
      ),
      const AdhkarCategory(
        title: 'أدعية الأنبياء',
        icon: '❤️',
      ),
      const AdhkarCategory(
        title: 'الرقية الشرعية',
        icon: '🤍',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFBF8),

        appBar: AppBar(
          backgroundColor: const Color(0xFFFCFBF8),
          elevation: 0,
          centerTitle: true,

          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20.sp,
              color: const Color(0xFF222222),
            ),
          ),

          title: Text(
            'الأذكار',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF222222),
            ),
          ),

          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.settings_outlined,
                size: 22.sp,
                color: const Color(0xFF222222),
              ),
            ),
          ],
        ),

        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 4.h),

                      _buildSearch(),

                      SizedBox(height: 14.h),

                      GridView.builder(
                        shrinkWrap: true,
                        physics:
                        const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 9.w,
                          mainAxisSpacing: 9.h,
                          childAspectRatio: 0.90,
                        ),
                        itemBuilder: (context, index) {
                          final category = categories[index];

                          return _buildCategoryCard(
                            context,
                            category,
                          );
                        },
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),

              // _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F1EB),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: TextField(
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'ابحث في الأذكار',
          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF999999),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20.sp,
            color: const Color(0xFF999999),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 11.h,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context,
      AdhkarCategory category,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: () {
        _openCategory(context, category);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFEFDF9),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: const Color(0xFFECE9E1),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 5.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F1E8),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                category.icon,
                style: TextStyle(
                  fontSize: 27.sp,
                ),
              ),
            ),

            SizedBox(height: 8.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Text(
                category.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCategory(
      BuildContext context,
      AdhkarCategory category,
      )
  {
    switch (category.title) {
      case 'أذكار الصباح':
        break;

      case 'أذكار المساء':
        break;

      case 'أذكار بعد الصلاة':
        break;

      case 'أذكار النوم':
        break;

      case 'أذكار الاستيقاظ':
        break;

      case 'أذكار المسجد':
        break;

      case 'أذكار الطعام':
        break;

      case 'حصن المسلم':
        break;

      case 'أذكار دخول المنزل':
        break;

      case 'أذكار الخروج من المنزل':
        break;

      case 'أذكار دخول الخلاء':
        break;

      case 'أذكار الخروج من الخلاء':
        break;

      case 'أذكار اللباس':
        break;

      case 'أذكار السفر':
        break;

      case 'أذكار المطر':
        break;

      case 'أذكار الرياح والرعد':
        break;

      case 'أذكار متنوعة':
        break;

      case 'أدعية من القرآن':
        break;

      case 'أدعية الأنبياء':
        break;

      case 'الرقية الشرعية':
        break;
    }
  }

  // Widget _buildBottomNavigation() {
  //   return Container(
  //     height: 68.h,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       border: Border(
  //         top: BorderSide(
  //           color: Colors.grey.shade200,
  //           width: 1.w,
  //         ),
  //       ),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //         _buildNavItem(
  //           icon: Icons.home_outlined,
  //           label: 'الرئيسية',
  //           active: false,
  //         ),
  //         _buildNavItem(
  //           icon: Icons.menu_book_outlined,
  //           label: 'القرآن',
  //           active: false,
  //         ),
  //         _buildNavItem(
  //           icon: Icons.auto_awesome,
  //           label: 'الأذكار',
  //           active: true,
  //         ),
  //         _buildNavItem(
  //           icon: Icons.mosque_outlined,
  //           label: 'الصلاة',
  //           active: false,
  //         ),
  //         _buildNavItem(
  //           icon: Icons.more_horiz,
  //           label: 'المزيد',
  //           active: false,
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _buildNavItem({
  //   required IconData icon,
  //   required String label,
  //   required bool active,
  // }) {
  //   const activeColor = Color(0xFF176B5B);
  //   const inactiveColor = Color(0xFF777777);
  //
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Icon(
  //         icon,
  //         size: 21.sp,
  //         color: active ? activeColor : inactiveColor,
  //       ),
  //
  //       SizedBox(height: 4.h),
  //
  //       Text(
  //         label,
  //         style: TextStyle(
  //           fontSize: 10.sp,
  //           fontWeight:
  //           active ? FontWeight.w700 : FontWeight.w500,
  //           color: active ? activeColor : inactiveColor,
  //         ),
  //       ),
  //     ],
  //   );
  // }
}

class AdhkarCategory {
  final String title;
  final String icon;

  const AdhkarCategory({
    required this.title,
    required this.icon,
  });
}