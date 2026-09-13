import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  @override
  Widget build(BuildContext context) {
    final isLoading =
        state.status == LocationStatus.loading;

    final primaryColor =
        Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading
            ? null
            : () async {
          final shouldUpdate =
          await showCurrentLocationDialog(context);

          if (!shouldUpdate) return;

          final ready =
          await CurrentLocationHelper
              .checkAndRequestPermission(context);

          if (!ready) return;

          if (!context.mounted) return;

          context.read<LocationBloc>().add(
            const GetCurrentLocation(),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              // ICON
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

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
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

                      SizedBox(height: 3.h),

                      Text(
                        '${state.currentLocation!.latitude.toStringAsFixed(4)}, '
                            '${state.currentLocation!.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              if (isLoading)
                SizedBox(
                  width: 22.w,
                  height: 22.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 17.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}