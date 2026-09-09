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

      // 9
      const AdhkarCategory(
        title: 'أذكار دخول المنزل',
        icon: '🚪',
      ),

      // 10
      const AdhkarCategory(
        title: 'أذكار الخروج من المنزل',
        icon: '🚶',
      ),

      // 11
      const AdhkarCategory(
        title: 'أذكار دخول الخلاء',
        icon: '🚻',
      ),

      // 12
      const AdhkarCategory(
        title: 'أذكار الخروج من الخلاء',
        icon: '🛁',
      ),

      // 13
      const AdhkarCategory(
        title: 'أذكار اللباس',
        icon: '👕',
      ),

      // 14
      const AdhkarCategory(
        title: 'أذكار السفر',
        icon: '🚗',
      ),

      // 15
      const AdhkarCategory(
        title: 'أذكار المطر',
        icon: '🌧️',
      ),

      // 16
      const AdhkarCategory(
        title: 'أذكار الرياح والرعد',
        icon: '🌩️',
      ),

      // 17
      const AdhkarCategory(
        title: 'أذكار متنوعة',
        icon: '🤲',
      ),

      // 18
      const AdhkarCategory(
        title: 'أدعية من القرآن',
        icon: '📖',
      ),

      // 19
      const AdhkarCategory(
        title: 'أدعية الأنبياء',
        icon: '❤️',
      ),

      // 20
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Color(0xFF222222),
            ),
          ),

          title: const Text(
            'الأذكار',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),

          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.settings_outlined,
                size: 22,
                color: Color(0xFF222222),
              ),
            ),
          ],
        ),

        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 4),

                      // Search
                      _buildSearch(),

                      const SizedBox(height: 14),

                      // Categories
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 9,
                          mainAxisSpacing: 9,
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

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Bottom Navigation
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F1EB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'ابحث في الأذكار',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Color(0xFF999999),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: Color(0xFF999999),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
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
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        _openCategory(context, category);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFEFDF9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFECE9E1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F1E8),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                category.icon,
                style: const TextStyle(
                  fontSize: 27,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              category.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
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
      ) {
    switch (category.title) {
      case 'أذكار الصباح':
      // Navigator.pushNamed(context, AppRouter.morningAdhkar);
        break;

      case 'أذكار المساء':
      // Navigator.pushNamed(context, AppRouter.eveningAdhkar);
        break;

      case 'أذكار بعد الصلاة':
      // Navigator.pushNamed(context, AppRouter.afterPrayerAdhkar);
        break;

      case 'أذكار النوم':
      // Navigator.pushNamed(context, AppRouter.sleepAdhkar);
        break;

      case 'أذكار الاستيقاظ':
      // Navigator.pushNamed(context, AppRouter.wakingAdhkar);
        break;

      case 'أذكار المسجد':
      // Navigator.pushNamed(context, AppRouter.mosqueAdhkar);
        break;

      case 'أذكار الطعام':
      // Navigator.pushNamed(context, AppRouter.foodAdhkar);
        break;

      case 'حصن المسلم':
      // Navigator.pushNamed(context, AppRouter.hisnMuslim);
        break;

      case 'أذكار دخول المنزل':
      // Navigator.pushNamed(context, AppRouter.enterHomeAdhkar);
        break;

      case 'أذكار الخروج من المنزل':
      // Navigator.pushNamed(context, AppRouter.leaveHomeAdhkar);
        break;

      case 'أذكار دخول الخلاء':
      // Navigator.pushNamed(context, AppRouter.enterBathroomAdhkar);
        break;

      case 'أذكار الخروج من الخلاء':
      // Navigator.pushNamed(context, AppRouter.leaveBathroomAdhkar);
        break;

      case 'أذكار اللباس':
      // Navigator.pushNamed(context, AppRouter.clothingAdhkar);
        break;

      case 'أذكار السفر':
      // Navigator.pushNamed(context, AppRouter.travelAdhkar);
        break;

      case 'أذكار المطر':
      // Navigator.pushNamed(context, AppRouter.rainAdhkar);
        break;

      case 'أذكار الرياح والرعد':
      // Navigator.pushNamed(context, AppRouter.windThunderAdhkar);
        break;

      case 'أذكار متنوعة':
      // Navigator.pushNamed(context, AppRouter.miscAdhkar);
        break;

      case 'أدعية من القرآن':
      // Navigator.pushNamed(context, AppRouter.quranDuas);
        break;

      case 'أدعية الأنبياء':
      // Navigator.pushNamed(context, AppRouter.prophetsDuas);
        break;

      case 'الرقية الشرعية':
      // Navigator.pushNamed(context, AppRouter.ruqyah);
        break;
    }
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            label: 'الرئيسية',
            active: false,
          ),
          _buildNavItem(
            icon: Icons.menu_book_outlined,
            label: 'القرآن',
            active: false,
          ),
          _buildNavItem(
            icon: Icons.auto_awesome,
            label: 'الأذكار',
            active: true,
          ),
          _buildNavItem(
            icon: Icons.mosque_outlined,
            label: 'الصلاة',
            active: false,
          ),
          _buildNavItem(
            icon: Icons.more_horiz,
            label: 'المزيد',
            active: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool active,
  }) {
    const activeColor = Color(0xFF176B5B);
    const inactiveColor = Color(0xFF777777);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 21,
          color: active ? activeColor : inactiveColor,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight:
            active ? FontWeight.w700 : FontWeight.w500,
            color: active ? activeColor : inactiveColor,
          ),
        ),
      ],
    );
  }
}

class AdhkarCategory {
  final String title;
  final String icon;

  const AdhkarCategory({
    required this.title,
    required this.icon,
  });
}