import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/router/app_router.dart';

class _NavItem {
  final IconData icon;
  final String label;
  final Color color;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CustomBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const List<_NavItem> _items = [
    _NavItem(
      color: Color(0xFF176B5B),
      icon: Icons.home_rounded,
      label: 'الرئيسية',
    ),
    _NavItem(
      color: Color(0xFF176B5B),
      icon: Icons.menu_book_outlined,
      label: 'القرآن',
    ),
    _NavItem(
      color: Color(0xFF176B5B),
      icon: Icons.auto_awesome_outlined,
      label: 'الأذكار',
    ),
    _NavItem(
      color: Color(0xFF176B5B),
      icon: Icons.mosque_outlined,
      label: 'الصلاة',
    ),
    _NavItem(
      color: Color(0xFF176B5B),
      icon: Icons.more_horiz_rounded,
      label: 'المزيد',
    ),
  ];

  Future<void> _handleTap(
      BuildContext context,
      int index,
      ) async {
    if (index == 0) {
      onSelected(0);
      return;
    }

    onSelected(index);

    switch (index) {
      case 1:
        await Navigator.pushNamed(
          context,
          AppRouter.quran,
        );
        break;

      case 2:
        await Navigator.pushNamed(
          context,
          AppRouter.adhkar,
        );
        break;

      case 3:
        break;

      case 4:
        break;
    }

    if (context.mounted) {
      onSelected(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6F0),
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          _items.length,
              (index) {
            final item = _items[index];
            final selected = selectedIndex == index;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _handleTap(
                context,
                index,
              ),
              child: SizedBox(
                width: 55.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 22.sp,
                      color: selected
                          ? item.color
                          : const Color(0xFF777777),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selected
                            ? item.color
                            : const Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}