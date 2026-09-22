import 'package:flutter/material.dart';

import '../../../azkar/presentation/pages/azkar_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../quran/presentation/pages/quran_page.dart';
import '../../../adhkar/presentation/pages/adhkar_page.dart';
import '../../../prayer_settings/presentation/pages/prayer_settings_page.dart';
import '../../../home/presentation/widget/buildBottomNavigation.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  late final List<Widget> pages = [
    const HomePage(),
    const QuranIndexPage(),
  const  AzkarPage(),
    const PrayerSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomBottomNavigation(
          selectedIndex: selectedIndex,
          onSelected: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}