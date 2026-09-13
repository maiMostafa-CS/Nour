import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/features/qibla/presentation/widgets/qibla_compass.dart';
import 'package:islamic_app/features/qibla/presentation/widgets/qibla_info_card.dart';

import '../bloc/bloc_state.dart';

class BuildLoaded extends StatelessWidget {
  QiblaState state;
      double? _heading;

   BuildLoaded({super.key,required this.state});

  @override
  Widget build(BuildContext context) {
    final qibla = state.qibla!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          SizedBox(height: 10.h),

          Text(
            'وجّه هاتفك نحو القبلة',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF176B5B),
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            'حرّك الهاتف حتى يشير السهم '
                'إلى اتجاه الكعبة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),

          SizedBox(height: 30.h),

          QiblaCompass(
            qiblaDirection: qibla.qiblaDirection,
            heading: _heading,
          ),

          SizedBox(height: 25.h),

          if (_heading != null)
            Text(
              'اتجاه الهاتف: '
                  '${_heading!.toStringAsFixed(0)}°',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),

          SizedBox(height: 20.h),

          QiblaInfoCard(
            qiblaDirection: qibla.qiblaDirection,
            latitude: qibla.latitude,
            longitude: qibla.longitude,
          ),

          SizedBox(height: 20.h),

          _buildHint(),
        ],
      ),
    );
  }
  Widget _buildHint() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF176B5B).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: const Color(0xFF176B5B),
            size: 24.sp,
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Text(
              'للحصول على قراءة أدق، أبعد '
                  'الهاتف عن الأجهزة المعدنية '
                  'وحركه بشكل رقم 8 لمعايرة البوصلة.',
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
