import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../injection_container.dart';
import '../bloc/bloc.dart';
import '../bloc/bloc_event.dart';
import '../bloc/bloc_state.dart';
import '../widgets/Build_loaded.dart';
import '../widgets/build_error.dart';
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
        return BuildError(
state: state,);

      case QiblaStatus.loaded:
        return BuildLoaded(
         state: state,
        );
    }
  }

  }
