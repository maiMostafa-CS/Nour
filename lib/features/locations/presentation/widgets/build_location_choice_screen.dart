import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/features/locations/presentation/widgets/build_manual_location_card.dart';

import '../bloc/bloc.dart';
import '../bloc/blocState.dart';
import '../pages/countrySelectionScreen.dart';
import 'currentLocationCard.dart';

class BuildLocationChoiceScreen extends StatefulWidget {
  LocationState state;

  BuildLocationChoiceScreen({
    super.key,
    required this.state,
  });

  @override
  State<BuildLocationChoiceScreen> createState() =>
      _BuildLocationChoiceScreenState();
}

class _BuildLocationChoiceScreenState
    extends State<BuildLocationChoiceScreen> {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 16.h),

          Text(
            'اختر موقعك',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            'اختر طريقة تحديد موقع الصلاة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),

          SizedBox(height: 32.h),

          // ======================================================
          // CURRENT LOCATION CARD
          // ======================================================

          CurrentLocationCard(
            state: widget.state,
          ),

          SizedBox(height: 16.h),

          // ======================================================
          // MANUAL LOCATION CARD
          // ======================================================

          BuildManualLocationCard(),
        ],
      ),
    );
  }
}