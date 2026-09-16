import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/helpers/network_helper.dart';
import '../bloc/bloc.dart';
import '../bloc/blocEvent.dart';
import '../bloc/blocState.dart';
import 'current_location_dialog.dart';
import 'current_location_helper.dart';

class CurrentLocationCard extends StatelessWidget {
  LocationState state;

  CurrentLocationCard({
    super.key,
    required this.state,
  });

  // ═══════════════════════════════════════════════════════════
  // التحقق من النت + GPS
  // ═══════════════════════════════════════════════════════════
  Future<bool> _checkRequirements(BuildContext context) async {
    // 1️⃣ تحقق من الإنترنت
    final hasInternet = await NetworkHelper.hasInternet();
    if (!hasInternet) {
      if (!context.mounted) return false;

      final openSettings = await _showDialog(
        context: context,
        icon: Icons.wifi_off,
        title: 'لا يوجد اتصال بالإنترنت',
        message: 'يحتاج التطبيق إلى الاتصال بالإنترنت '
            'لتحديد موقعك بدقة والحصول على اسم المدينة.\n\n'
            'يرجى تفعيل Wi-Fi أو بيانات الجوال.',
      );

      if (openSettings == true) {
        // ⚠️ افتح إعدادات الشبكة
        await Geolocator.openLocationSettings();
      }

      return false;
    }

    // 2️⃣ تحقق من GPS
    final gpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!gpsEnabled) {
      if (!context.mounted) return false;

      final openSettings = await _showDialog(
        context: context,
        icon: Icons.location_off,
        title: 'الموقع غير مفعّل',
        message: 'يحتاج التطبيق إلى تفعيل خدمة الموقع (GPS) '
            'للحصول على موقعك الحالي.',
      );

      if (openSettings == true) {
        await Geolocator.openLocationSettings();
      }

      return false;
    }

    return true;
  }

  // ═══════════════════════════════════════════════════════════
  // Dialog موحد
  // ═══════════════════════════════════════════════════════════
  Future<bool?> _showDialog({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(icon, color: Colors.orange, size: 40),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // onTap
  // ═══════════════════════════════════════════════════════════
  Future<void> _onTap(BuildContext context, bool isLoading) async {
    if (isLoading) return;

    // 1️⃣ تحقق من النت + GPS
    final ready = await _checkRequirements(context);
    if (!ready || !context.mounted) return;

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
    final isLoading = state.status == LocationStatus.loading;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onTap(context, isLoading),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Container(
                width: 58.w,
                height: 58.h,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.my_location,
                  size: 28.sp,
                  color: primaryColor,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'استخدام الموقع الحالي',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'تحديد موقعك تلقائيًا باستخدام GPS',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (state.currentLocation != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        '${state.currentLocation!.city}, '
                            '${state.currentLocation!.country}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 22.w,
                  height: 22.h,
                  child: CircularProgressIndicator(strokeWidth: 2.w),
                )
              else
                Icon(Icons.arrow_forward_ios, size: 17.sp),
            ],
          ),
        ),
      ),
    );
  }
}