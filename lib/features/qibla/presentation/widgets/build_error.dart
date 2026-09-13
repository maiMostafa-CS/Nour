import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/bloc.dart';
import '../bloc/bloc_event.dart';
import '../bloc/bloc_state.dart';

class BuildError extends StatelessWidget {
  QiblaState state;
   BuildError({super.key,required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(25.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_rounded,
              size: 70.sp,
              color: const Color(0xFF176B5B),
            ),

            SizedBox(height: 20.h),

            Text(
              state.errorMessage ?? 'حدث خطأ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                height: 1.5,
              ),
            ),

            SizedBox(height: 20.h),

            ElevatedButton(
              onPressed: () {
                context.read<QiblaBloc>().add(
                  const QiblaRetry(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF176B5B),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 30.w,
                  vertical: 14.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
