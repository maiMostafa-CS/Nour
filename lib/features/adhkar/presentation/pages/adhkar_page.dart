// import 'package:flutter/material.dart';
// import 'package:azkary/azkary.dart';
//
// class AzkarScreen extends StatelessWidget {
//   const AzkarScreen({super.key});
//
//   static const Color backgroundColor = Color(0xFFFCF5D7);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         title: const Text(
//           'الأذكار',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: backgroundColor,
//         elevation: 0,
//       ),
//       body: FutureBuilder(
//         future: Azkary.instance.getCategories(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//
//           if (snapshot.hasError) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Text(
//                   'حدث خطأ أثناء تحميل الأذكار:\n${snapshot.error}',
//                   textAlign: TextAlign.center,
//                   textDirection: TextDirection.rtl,
//                 ),
//               ),
//             );
//           }
//
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//               child: Text(
//                 'لا توجد أذكار متاحة',
//                 textDirection: TextDirection.rtl,
//               ),
//             );
//           }
//
//           final categories = snapshot.data!;
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: categories.length,
//             itemBuilder: (context, index) {
//               final category = categories[index];
//
//               return Card(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 elevation: 1,
//                 child: ListTile(
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 8,
//                   ),
//                   title: Text(
//                     category.name,
//                     textDirection: TextDirection.rtl,
//                     style: const TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   trailing: const Icon(
//                     Icons.arrow_back_ios_new,
//                     size: 18,
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => AzkarDetailScreen(
//                           category: category,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// class AzkarDetailScreen extends StatefulWidget {
//   final ZekrCategory category;
//
//   const AzkarDetailScreen({
//     super.key,
//     required this.category,
//   });
//
//   @override
//   State<AzkarDetailScreen> createState() => _AzkarDetailScreenState();
// }
//
// class _AzkarDetailScreenState extends State<AzkarDetailScreen> {
//   late final List<int> _counters;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _counters = List<int>.filled(
//       widget.category.azkar.length,
//       0,
//     );
//   }
//
//   void _incrementZekr(int index) {
//     final zekr = widget.category.azkar[index];
//     final currentCount = _counters[index];
//
// // لا نزيد عن العدد المطلوب
//     if (currentCount >= zekr.count) {
//       return;
//     }
//
//     setState(() {
//       _counters[index]++;
//     });
//   }
//
//   void _resetZekr(int index) {
//     setState(() {
//       _counters[index] = 0;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final azkarList = widget.category.azkar;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFFCF5D7),
//       appBar: AppBar(
//         title: Text(
//           widget.category.name,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: const Color(0xFFFCF5D7),
//         elevation: 0,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: azkarList.length,
//         itemBuilder: (context, index) {
//           final zekr = azkarList[index];
//
//           final currentCount = _counters[index];
//           final requiredCount = zekr.count;
//
//           final isCompleted = currentCount >= requiredCount;
//
//           return Card(
//             margin: const EdgeInsets.only(bottom: 16),
//             elevation: 1,
//             child: Padding(
//               padding: const EdgeInsets.all(18),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: Text(
//                       'ذكر ${index + 1}',
//                       textDirection: TextDirection.rtl,
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 13,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     zekr.text,
//                     textAlign: TextAlign.center,
//                     textDirection: TextDirection.rtl,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       height: 2,
//                       fontFamily: 'Amiri',
//                     ),
//                   ),
//                   const SizedBox(height: 18),
//                   Text(
//                     'المطلوب: $requiredCount',
//                     textAlign: TextAlign.center,
//                     textDirection: TextDirection.rtl,
//                     style: TextStyle(
//                       color: Colors.grey[700],
//                       fontSize: 14,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '$currentCount / $requiredCount',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: isCompleted ? Colors.green : Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   LinearProgressIndicator(
//                     value: requiredCount > 0
//                         ? (currentCount / requiredCount).clamp(0.0, 1.0)
//                         : 0.0,
//                     minHeight: 7,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   const SizedBox(height: 18),
//                   SizedBox(
//                     height: 50,
//                     child: ElevatedButton.icon(
//                       onPressed:
//                           isCompleted ? null : () => _incrementZekr(index),
//                       icon: Icon(
//                         isCompleted ? Icons.check : Icons.add,
//                       ),
//                       label: Text(
//                         isCompleted ? 'تم إكمال الذكر' : 'احسب الذكر',
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFFCF5D7),
//                         foregroundColor: Colors.black87,
//                         disabledBackgroundColor:
//                             Colors.green.withValues(alpha: 0.2),
//                         disabledForegroundColor: Colors.green,
//                         elevation: 0,
//                       ),
//                     ),
//                   ),
//                   if (currentCount > 0) ...[
//                     const SizedBox(height: 8),
//                     TextButton.icon(
//                       onPressed: () => _resetZekr(index),
//                       icon: const Icon(
//                         Icons.refresh,
//                         size: 18,
//                       ),
//                       label: const Text('إعادة العداد'),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
