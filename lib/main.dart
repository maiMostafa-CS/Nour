import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app.dart';
import 'core/services/alarm_cleanup/orphan_alarm_cleaner.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/adhan_scheduler_service.dart';
import 'core/services/prayer_scheduler_split/prayer_scheduler/notifications/countdown_notification_service.dart';
import 'core/services/unlock_card.dart';
import 'features/khatma/domain/useCase/get_current_khatma_ayah.dart';
import 'features/khatma/domain/useCase/get_khatma_weekly_report.dart';
import 'features/khatma/domain/useCase/markCurrent_ayahAs_read.dart';
import 'features/khatma/services/khatma_unlock_service.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  // 1️⃣ سجّل التبعيات
  await configureDependencies();
  await Alarm.init();

  if (Platform.isAndroid) {
    try {
      final cleaner = sl<OrphanAlarmCleaner>();
      await cleaner.cleanOrphans();
    } catch (e, st) {
      debugPrint('❌ [main] cleanOrphans failed: $e');
      debugPrint('$st');
    }
  }

  // 3️⃣ سجّل Khatma handler
  if (Platform.isAndroid) {
    KhatmaUnlockSyncService.setKhatmaReadHandler(_onNativeKhatmaRead);
  }

  // 4️⃣ شغّل التطبيق
  runApp(const IslamicApp());

  // 5️⃣ بعد ما التطبيق يظهر — نفّذ الـ setup
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _initializeKhatmaUnlock();
    await _backgroundSetup();
  });
}

Future<void> _initializeKhatmaUnlock() async {
  if (!Platform.isAndroid) {
    return;
  }

  try {
    await _syncKhatmaUnlockAyah();
    await _restoreUnlockCard();

    debugPrint('✅ KHATMA UNLOCK: initialization completed');
  } catch (e, stackTrace) {
    debugPrint('❌ KHATMA UNLOCK INITIALIZATION FAILED: $e');
    debugPrint('$stackTrace');
  }
}

Future<void> _restoreUnlockCard() async {
  if (!Platform.isAndroid) return;
  if (await UnlockCard.isEnabled() && await UnlockCard.hasOverlayPermission()) {
    await UnlockCard.start();
  }
}

Future<void> _backgroundSetup() async {
  final sw = Stopwatch()..start();

  try {
    // ============================================================
    // Adhan Scheduler
    // ============================================================

    final adhanScheduler = AdhanSchedulerService();

    await adhanScheduler.initialize();

    debugPrint(
      '⏱️ adhanScheduler.initialize: ${sw.elapsedMilliseconds}ms',
    );

    sw.reset();

    // ============================================================
    // Exact Alarm Permission
    // ============================================================

    await checkAndroidScheduleExactAlarmPermission();

    debugPrint(
      '⏱️ permission: ${sw.elapsedMilliseconds}ms',
    );

    sw.reset();

    // ============================================================
    // Battery Optimization
    // ============================================================

    await adhanScheduler.requestBatteryOptimizationExemption();

    debugPrint(
      '⏱️ battery: ${sw.elapsedMilliseconds}ms',
    );
  } catch (e, stackTrace) {
    debugPrint('❌ Background setup failed: $e');
    debugPrint('$stackTrace');
  }
}

Future<void> checkAndroidScheduleExactAlarmPermission() async {
  final status = await Permission.scheduleExactAlarm.status;

  prayerSchedulerLog(
    '📋 Schedule exact alarm permission: $status',
  );

  if (status.isDenied) {
    final result = await Permission.scheduleExactAlarm.request();

    prayerSchedulerLog(
      '📋 Schedule exact alarm permission after request: $result',
    );
  }
}

Future<void> _syncKhatmaUnlockAyah() async {
  if (!Platform.isAndroid) {
    return;
  }

  try {
    final getCurrentKhatmaAyah = sl<GetCurrentKhatmaAyah>();

    final ayah = await getCurrentKhatmaAyah();

    if (ayah == null) {
      debugPrint('🌿 KHATMA UNLOCK: no current ayah');
      return;
    }

    await KhatmaUnlockSyncService.saveCurrentAyah(ayah);

    debugPrint(
      '✅ KHATMA UNLOCK: synced '
          'global=${ayah.globalNumber} '
          'surah=${ayah.surahName} '
          'ayah=${ayah.ayahNumber} '
          'page=${ayah.pageNumber}',
    );
  } catch (e, stackTrace) {
    debugPrint('❌ KHATMA UNLOCK SYNC FAILED: $e');
    debugPrint('$stackTrace');
  }
}

Future<void> _onNativeKhatmaRead() async {
  try {
    debugPrint('📖 KHATMA: Native requested read');

    // 1. Mark current ayah as read
    final markCurrentAyahAsRead = sl<MarkCurrentAyahAsRead>();
    final progress = await markCurrentAyahAsRead();

    debugPrint(
      '✅ KHATMA: '
          'currentAyah=${progress.currentAyah}, '
          'readAyahs=${progress.readAyahs}',
    );

    // 2. Get weekly report
    final getKhatmaWeeklyReport = sl<GetKhatmaWeeklyReport>();
    final report = await getKhatmaWeeklyReport();

    debugPrint(
      '📊 KHATMA WEEKLY: '
          'total=${report.totalAyahs}, '
          'currentWeek=${report.currentWeekAyahs}, '
          'week=${report.weekNumber}',
    );

    // 3. Send weekly report to Android
    await KhatmaUnlockSyncService.saveWeeklyReport(
      totalAyahs: report.totalAyahs,
      currentWeekAyahs: report.currentWeekAyahs,
      weekNumber: report.weekNumber,
    );

    debugPrint('✅ KHATMA WEEKLY: report synced to Android');

    // 4. Sync next ayah to Android
    await _syncKhatmaUnlockAyah();

    debugPrint('✅ KHATMA: New ayah synced');
  } catch (e, stackTrace) {
    debugPrint('❌ KHATMA READ FAILED: $e');
    debugPrint('$stackTrace');
  }
}





// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const IslamicPrayerApp());
// }
//
// class IslamicPrayerApp extends StatelessWidget {
//   const IslamicPrayerApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'مواقيت الصلاة والأذكار',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         fontFamily: 'Tajawal',
//         scaffoldBackgroundColor: const Color(0xFFF8FAFC),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF0F766E),
//           primary: const Color(0xFF0D5C4E),
//         ),
//       ),
//       home: const Directionality(
//         textDirection: TextDirection.rtl,
//         child: PrayerHomeScreen(),
//       ),
//     );
//   }
// }
//
// class PrayerHomeScreen extends StatefulWidget {
//   const PrayerHomeScreen({super.key});
//
//   @override
//   State<PrayerHomeScreen> createState() => _PrayerHomeScreenState();
// }
//
// class _PrayerHomeScreenState extends State<PrayerHomeScreen> {
//   int _currentIndex = 0;
//   int _tasbeehCount = 33;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         top: false,
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               _buildTopHeroHeader(context),
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16.0,
//                   vertical: 16.0,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildPrayerTimesRow(),
//                     const SizedBox(height: 20),
//                     _buildSectionTitle(
//                       'الوحدات والخدمات الذكية',
//                       actionText: 'تخصيص',
//                     ),
//                     const SizedBox(height: 12),
//                     _buildServicesGrid(),
//                     const SizedBox(height: 20),
//                     _buildAyahOfTheDayCard(),
//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: const Color(0xFF059669),
//         unselectedItemColor: Colors.grey.shade400,
//         selectedLabelStyle: const TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 11,
//         ),
//         unselectedLabelStyle: const TextStyle(fontSize: 11),
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_rounded),
//             label: 'الرئيسية',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.menu_book_rounded),
//             label: 'القرآن',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.auto_awesome_rounded),
//             label: 'الأذكار',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings_rounded),
//             label: 'الإعدادات',
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 1. ترويسة الشاشة مع بطاقة الصلاة القادمة والعداد
//   Widget _buildTopHeroHeader(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 12,
//         bottom: 24,
//         left: 16,
//         right: 16,
//       ),
//       decoration: const BoxDecoration(
//         color: Color(0xFF06231C),
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // شريط الموقع والأيقونات العلوية
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 5,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF0D3B30),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: Colors.tealAccent.withOpacity(0.2),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 7,
//                       height: 7,
//                       decoration: const BoxDecoration(
//                         color: Color(0xFF34D399),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     const Text(
//                       'أولى الهرم، الجيزة • GPS',
//                       style: TextStyle(
//                         color: Color(0xFFA7F3D0),
//                         fontSize: 11,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Row(
//                 children: [
//                   _buildCircleHeaderButton(Icons.explore_outlined),
//                   const SizedBox(width: 8),
//                   _buildCircleHeaderButton(Icons.notifications_none_rounded),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           // التاريخ الهجري والميلادي
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: const [
//                   Text(
//                     'الأحد، 9 ربيع الآخر',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 17,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     '21 سبتمبر 2026 م • القاهرة',
//                     style: TextStyle(
//                       color: Color(0xFF94A3B8),
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 8,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF031612),
//                   borderRadius: BorderRadius.circular(6),
//                   border: Border.all(color: const Color(0xFF065F46)),
//                 ),
//                 child: const Text(
//                   '1448 هـ',
//                   style: TextStyle(
//                     color: Color(0xFF6EE7B7),
//                     fontSize: 11,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           // بطاقة الصلاة المميزة
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF0D4337), Color(0xFF052720)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: const Color(0xFF34D399).withOpacity(0.25)),
//
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 3,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.teal.shade900.withOpacity(0.6),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Row(
//                         children: [
//                           Icon(
//                             Icons.circle,
//                             size: 6,
//                             color: Color(0xFF34D399),
//                           ),
//                           SizedBox(width: 4),
//                           Text(
//                             'الصلاة القادمة',
//                             style: TextStyle(
//                               color: Color(0xFFA7F3D0),
//                               fontSize: 11,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const Row(
//                       children: [
//                         Icon(
//                           Icons.volume_up_outlined,
//                           size: 14,
//                           color: Color(0xFF34D399),
//                         ),
//                         SizedBox(width: 4),
//                         Text(
//                           'أذان الحرم المكي',
//                           style: TextStyle(
//                             color: Colors.white70,
//                             fontSize: 11,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'صلاة العصر',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 26,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 6,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.black26,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: const Text(
//                         'PM 4:16',
//                         style: TextStyle(
//                           color: Color(0xFF6EE7B7),
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 // صندوق العداد التنازلي
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 8,
//                     horizontal: 16,
//                   ),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF031612),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: Colors.teal.withOpacity(0.3),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: const [
//                       Text(
//                         'متبقي',
//                         style: TextStyle(
//                           color: Color(0xFF34D399),
//                           fontSize: 12,
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       Text(
//                         '00:01:49',
//                         style: TextStyle(
//                           color: Color(0xFF6EE7B7),
//                           fontSize: 26,
//                           fontWeight: FontWeight.w900,
//                           letterSpacing: 2,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 // شريط نسبة انقضاء وقت الصلاة
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: const [
//                     Text(
//                       'الظهر (12:49)',
//                       style: TextStyle(
//                         color: Colors.white60,
//                         fontSize: 10,
//                       ),
//                     ),
//                     Text(
//                       '98% انقضى',
//                       style: TextStyle(
//                         color: Color(0xFF34D399),
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       'العصر (4:16)',
//                       style: TextStyle(
//                         color: Colors.white60,
//                         fontSize: 10,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: const LinearProgressIndicator(
//                     value: 0.98,
//                     backgroundColor: Color(0xFF03221C),
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       Color(0xFF10B981),
//                     ),
//                     minHeight: 5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 2. شريط مواقيت الصلاة الأفقية
//   Widget _buildPrayerTimesRow() {
//     final prayers = [
//       {
//         'name': 'الفجر',
//         'time': '5:15',
//         'icon': Icons.wb_twilight_rounded,
//         'active': false,
//       },
//       {
//         'name': 'الشروق',
//         'time': '6:42',
//         'icon': Icons.wb_sunny_outlined,
//         'active': false,
//       },
//       {
//         'name': 'الظهر',
//         'time': '12:49',
//         'icon': Icons.sunny,
//         'active': false,
//       },
//       {
//         'name': 'العصر',
//         'time': '4:16',
//         'icon': Icons.cloud_queue_rounded,
//         'active': true,
//       },
//       {
//         'name': 'المغرب',
//         'time': '6:54',
//         'icon': Icons.nights_stay_outlined,
//         'active': false,
//       },
//     ];
//
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'مواقيت اليوم',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF0F172A),
//               ),
//             ),
//             TextButton(
//               onPressed: () {},
//               style: TextButton.styleFrom(
//                 padding: EdgeInsets.zero,
//                 minimumSize: const Size(50, 30),
//               ),
//               child: const Row(
//                 children: [
//                   Text(
//                     'جدول الشهر',
//                     style: TextStyle(
//                       color: Color(0xFF047857),
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Icon(
//                     Icons.chevron_left_rounded,
//                     size: 16,
//                     color: Color(0xFF047857),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 6),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: prayers.map((p) {
//             final isActive = p['active'] as bool;
//             return Expanded(
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 2.5),
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 decoration: BoxDecoration(
//                   color: isActive ? const Color(0xFF059669) : Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: isActive
//                         ? const Color(0xFF34D399)
//                         : Colors.grey.shade200,
//                   ),
//                   boxShadow: [
//                     if (isActive)
//                       BoxShadow(
//                         color: const Color(0xFF059669).withOpacity(0.3),
//                         blurRadius: 6,
//                         offset: const Offset(0, 3),
//                       )
//                     else
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.02),
//                         blurRadius: 4,
//                       ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       p['name'] as String,
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: isActive ? Colors.white : Colors.grey.shade600,
//                         fontWeight:
//                         isActive ? FontWeight.bold : FontWeight.normal,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Icon(
//                       p['icon'] as IconData,
//                       size: 16,
//                       color: isActive ? Colors.white : Colors.amber.shade700,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       p['time'] as String,
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color:
//                         isActive ? Colors.white : const Color(0xFF1E293B),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
//
//   // 3. شبكة الخدمات والبطاقات الأربعة (2 × 2)
//   Widget _buildServicesGrid() {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       mainAxisSpacing: 12,
//       crossAxisSpacing: 12,
//       childAspectRatio: 1.15,
//       children: [
//         // بطاقة المصحف
//         _buildServiceCard(
//           icon: Icons.auto_stories_rounded,
//           iconBg: const Color(0xFFECFDF5),
//           iconColor: const Color(0xFF059669),
//           title: 'المصحف الذكي',
//           subtitle: 'سورة الكهف • ص ٢٩٣',
//           bottomWidget: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: const [
//                   Text(
//                     'الجزء ١٥',
//                     style: TextStyle(fontSize: 10, color: Colors.grey),
//                   ),
//                   Text(
//                     '68%',
//                     style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF059669),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 3),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(6),
//                 child: const LinearProgressIndicator(
//                   value: 0.68,
//                   backgroundColor: Color(0xFFE2E8F0),
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     Color(0xFF059669),
//                   ),
//                   minHeight: 4,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         // بطاقة عداد التسبيح التفاعلية
//         _buildServiceCard(
//           icon: Icons.fingerprint_rounded,
//           iconBg: const Color(0xFFF1F5F9),
//           iconColor: const Color(0xFF475569),
//           title: 'عداد التسبيح',
//           subtitle: 'سبحان الله وبحمده',
//           bottomWidget: InkWell(
//             onTap: () {
//               setState(() {
//                 if (_tasbeehCount < 100) _tasbeehCount++;
//               });
//             },
//             borderRadius: BorderRadius.circular(8),
//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                 vertical: 4,
//                 horizontal: 8,
//               ),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFECFDF5),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: const Color(0xFFA7F3D0)),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'اضغط للعد',
//                     style: TextStyle(
//                       color: Color(0xFF065F46),
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 5,
//                       vertical: 1,
//                     ),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF059669),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       '$_tasbeehCount / 100',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 9,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         // بطاقة اتجاه القبلة
//         _buildServiceCard(
//           icon: Icons.navigation_rounded,
//           iconBg: const Color(0xFFF0FDFA),
//           iconColor: const Color(0xFF0D9488),
//           title: 'اتجاه القبلة',
//           subtitle: 'SE 136° نحو مكة',
//           bottomWidget: Container(
//             padding: const EdgeInsets.symmetric(vertical: 3),
//             decoration: BoxDecoration(
//               color: const Color(0xFFCCFBF1),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             alignment: Alignment.center,
//             child: const Text(
//               '🎯 قفل الهدف نحو الكعبة',
//               style: TextStyle(
//                 color: Color(0xFF0F766E),
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//         // بطاقة مفكرة العبادات والالتزام
//         _buildServiceCard(
//           icon: Icons.calendar_month_rounded,
//           iconBg: const Color(0xFFFAF5FF),
//           iconColor: const Color(0xFF9333EA),
//           title: 'مفكرة العبادات',
//           subtitle: 'أيام البيض بعد 5 أيام',
//           bottomWidget: Container(
//             padding: const EdgeInsets.symmetric(vertical: 3),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF3E8FF),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             alignment: Alignment.center,
//             child: const Text(
//               '🔥 14 يوماً التزام متواصل',
//               style: TextStyle(
//                 color: Color(0xFF7E22CE),
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // 4. بطاقة آية اليوم
//   Widget _buildAyahOfTheDayCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF07271F),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xFF065F46)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: const [
//               Text(
//                 '✦ آية اليوم المؤثرة',
//                 style: TextStyle(
//                   color: Color(0xFF34D399),
//                   fontSize: 11,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Icon(Icons.share_outlined, size: 16, color: Colors.white60),
//             ],
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             '﴿ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ ﴾',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Color(0xFFE2E8F0),
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               height: 1.8,
//             ),
//           ),
//           const SizedBox(height: 4),
//           const Text(
//             '[سورة الرعد: ٢٨]',
//             style: TextStyle(color: Color(0xFF6EE7B7), fontSize: 11),
//           ),
//           const SizedBox(height: 12),
//           // مشغل صوت الآية
//           Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 6,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.black26,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   '0:14 / 0:38',
//                   style: TextStyle(color: Colors.white60, fontSize: 10),
//                 ),
//                 Row(
//                   children: List.generate(
//                     12,
//                         (i) => Container(
//                       width: 3,
//                       height: (i % 3 + 1) * 6.0,
//                       margin: const EdgeInsets.symmetric(horizontal: 1.5),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF34D399),
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: const BoxDecoration(
//                     color: Color(0xFF10B981),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.play_arrow_rounded,
//                     size: 16,
//                     color: Color(0xFF06231C),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // عناصر مساعدة
//   Widget _buildCircleHeaderButton(IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(7),
//       decoration: BoxDecoration(
//         color: const Color(0xFF0D3B30),
//         shape: BoxShape.circle,
//         border: Border.all(
//           color: Colors.tealAccent.withOpacity(0.15),
//         ),
//       ),
//       child: Icon(icon, size: 16, color: const Color(0xFFA7F3D0)),
//     );
//   }
//
//   Widget _buildSectionTitle(String title, {String? actionText}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF0F172A),
//           ),
//         ),
//         if (actionText != null)
//           Text(
//             actionText,
//             style: const TextStyle(fontSize: 11, color: Colors.grey),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildServiceCard({
//     required IconData icon,
//     required Color iconBg,
//     required Color iconColor,
//     required String title,
//     required String subtitle,
//     required Widget bottomWidget,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.02),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: iconBg,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(icon, size: 16, color: iconColor),
//               ),
//               const Icon(
//                 Icons.arrow_forward_ios_rounded,
//                 size: 10,
//                 color: Colors.black26,
//               ),
//             ],
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1E293B),
//                 ),
//               ),
//               const SizedBox(height: 1),
//               Text(
//                 subtitle,
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: Colors.grey.shade500,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//           bottomWidget,
//         ],
//       ),
//     );
//   }
// }