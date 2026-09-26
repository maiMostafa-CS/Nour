import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../azkar/presentation/pages/azkar_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../quran/presentation/pages/quran_page.dart';
import '../../../prayer_settings/presentation/pages/prayer_settings_page.dart';
import '../../../home/presentation/widget/buildBottomNavigation.dart';
import '../../../../core/theme/app_colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  late final List<Widget> pages = const [
    HomePage(),
    QuranIndexPage(),
    AzkarPage(),
    PrayerSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (selectedIndex != 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => selectedIndex = 0);
            }
          });
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.creamBg,
        body: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: CustomBottomNavigation(
            selectedIndex: selectedIndex,
            onSelected: (index) {
              setState(() => selectedIndex = index);
            },
          ),
        ),
      ),
    );
  }
}