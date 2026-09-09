// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/prayer_bloc.dart';
//
// /// Settings screen: one switch to turn the 30-day background prayer
// /// notifications on/off, plus a manual "renew" button.
// ///
// /// [latitude]/[longitude] should be whatever coordinates you already use
// /// to calculate today's prayer times elsewhere in the app (the same ones
// /// you pass into PrayerLocalDataSource.calculate()).
// class PrayerNotificationSettingsPage extends StatelessWidget {
//   final double latitude;
//   final double longitude;
//
//   const PrayerNotificationSettingsPage({
//     super.key,
//     required this.latitude,
//     required this.longitude,
//   });
//
//   static const int _defaultDays = 30;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('تنبيهات الصلاة')),
//       body: BlocConsumer<PrayerNotificationBloc, PrayerNotificationState>(
//         listener: (context, state) {
//           if (state.status == PrayerNotificationStatus.failure) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('حصل خطأ أثناء الجدولة: ${state.errorMessage ?? ''}'),
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           final isScheduled =
//               state.status == PrayerNotificationStatus.scheduled;
//           final isLoading = state.status == PrayerNotificationStatus.loading;
//
//           return ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               Card(
//                 child: SwitchListTile(
//                   title: const Text('تفعيل تنبيهات الأذان لمدة 30 يوم'),
//                   subtitle: Text(
//                     isScheduled
//                         ? 'مفعّلة الآن — تغطي ${state.scheduledDays} يوم قادمة بدون فتح التطبيق'
//                         : 'غير مفعّلة حاليًا',
//                   ),
//                   value: isScheduled,
//                   onChanged: isLoading ? null : (enabled) => _onToggled(context, enabled),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               if (isLoading)
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                   child: Center(child: CircularProgressIndicator()),
//                 ),
//               OutlinedButton.icon(
//                 onPressed: isLoading ? null : () => _onRenewPressed(context),
//                 icon: const Icon(Icons.refresh),
//                 label: const Text('تحديث / تجديد الجدولة الآن'),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'ملحوظة: بعد انتهاء الـ 30 يوم، افتح التطبيق مرة على الأقل '
//                     'عشان يجدّد الجدولة تلقائيًا لمدة 30 يوم إضافية.',
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   void _onToggled(BuildContext context, bool enabled) {
//     if (enabled) {
//       context.read<PrayerNotificationBloc>().add(
//         ScheduleNotificationsRequested(
//           latitude: latitude,
//           longitude: longitude,
//           days: _defaultDays,
//         ),
//       );
//     } else {
//       context
//           .read<PrayerNotificationBloc>()
//           .add(const CancelNotificationsRequested());
//     }
//   }
//
//   void _onRenewPressed(BuildContext context) {
//     context.read<PrayerNotificationBloc>().add(
//       RescheduleNotificationsRequested(
//         latitude: latitude,
//         longitude: longitude,
//         days: _defaultDays,
//       ),
//     );
//   }
// }