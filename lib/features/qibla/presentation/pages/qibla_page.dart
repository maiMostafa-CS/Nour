import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../injection_container.dart';
import '../bloc/bloc.dart';
import '../bloc/bloc_event.dart';
import '../bloc/bloc_state.dart';
import '../widgets/qibla_compass.dart';
import '../widgets/qibla_info_card.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  double? _heading;

  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();

    _startCompass();
  }

  void _startCompass() {
    _compassSubscription = FlutterCompass.events?.listen(
          (event) {
        if (!mounted) return;

        setState(() {
          _heading = event.heading;
        });
      },
    );
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QiblaBloc>()
        ..add(const QiblaStarted()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F3EA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F3EA),
          elevation: 0,
          centerTitle: true,
          title: Text(
            'اتجاه القبلة',
            style: TextStyle(
              color: const Color(0xFF176B5B),
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          iconTheme: IconThemeData(
            color: const Color(0xFF176B5B),
            size: 24.sp,
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<QiblaBloc, QiblaState>(
            builder: (context, state) {
              return _buildBody(
                context,
                state,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      QiblaState state,
      ) {
    switch (state.status) {
      case QiblaStatus.initial:
      case QiblaStatus.loading:
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF176B5B),
          ),
        );

      case QiblaStatus.error:
        return _buildError(
          context,
          state,
        );

      case QiblaStatus.loaded:
        return _buildLoaded(
          state,
        );
    }
  }

  Widget _buildLoaded(
      QiblaState state,
      ) {
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

  Widget _buildError(
      BuildContext context,
      QiblaState state,
      ) {
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