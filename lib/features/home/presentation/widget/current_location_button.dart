import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../locations/presentation/bloc/bloc.dart';
import '../../../locations/presentation/bloc/blocEvent.dart';
import '../../../locations/presentation/widgets/current_location_dialog.dart';
import '../../../locations/presentation/widgets/current_location_helper.dart';

class CurrentLocationButton extends StatelessWidget {
  const CurrentLocationButton({super.key});

  // Future<bool> _checkGpsAndInternet(BuildContext context) async {
  //   final gpsEnabled = await Geolocator.isLocationServiceEnabled();
  //
  //   if (gpsEnabled) return true;
  //   if (!context.mounted) return false;
  //
  //   final shouldOpenSettings = await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (ctx) => AlertDialog(
  //       icon: const Icon(Icons.location_off, color: Colors.orange),
  //       title: const Text('الموقع غير مفعّل'),
  //       content: const Text(
  //         'من فضلك افتح خدمة الموقع (GPS) '
  //             'والاتصال بالإنترنت للحصول على موقعك.',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx, false),
  //           child: const Text('إلغاء'),
  //         ),
  //         ElevatedButton.icon(
  //           onPressed: () => Navigator.pop(ctx, true),
  //           icon: const Icon(Icons.settings, size: 18),
  //           label: const Text('فتح الإعدادات'),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   if (shouldOpenSettings == true) {
  //     await Geolocator.openLocationSettings();
  //     await Future.delayed(const Duration(seconds: 1));
  //     return await Geolocator.isLocationServiceEnabled();
  //   }
  //
  //   return false;
  // }

  Future<void> _updateLocation(BuildContext context) async {
    // 1️⃣ تحقق من GPS
    // final ready = await _checkGpsAndInternet(context);
    // if (!ready || !context.mounted) return;

    // 2️⃣ اسأل المستخدم
    final shouldUpdate = await showCurrentLocationDialog(context);
    if (!shouldUpdate || !context.mounted) return;

    // 3️⃣ تحقق من الصلاحيات
    final hasPermission =
    await CurrentLocationHelper.checkAndRequestPermission(context);
    if (!hasPermission || !context.mounted) return;

    // 4️⃣ حدّث الموقع
    context.read<LocationBloc>().add(
      const GetCurrentLocation(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _updateLocation(context),
      icon: const Icon(Icons.location_on_outlined),
    );
  }
}