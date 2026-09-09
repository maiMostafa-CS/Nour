import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../../../../injection_container.dart';
import '../bloc/bloc.dart';
import '../bloc/bloc_event.dart';
import '../bloc/bloc_state.dart';
import '../widgets/qibla_compass.dart';
import '../widgets/qibla_info_card.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() =>
      _QiblaPageState();
}

class _QiblaPageState
    extends State<QiblaPage> {
  double? _heading;

  StreamSubscription<CompassEvent>?
  _compassSubscription;

  @override
  void initState() {
    super.initState();

    _startCompass();
  }

  void _startCompass() {
    _compassSubscription =
        FlutterCompass.events?.listen(
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
        backgroundColor:
        const Color(0xFFF8F3EA),

        appBar: AppBar(
          backgroundColor:
          const Color(0xFFF8F3EA),

          elevation: 0,

          centerTitle: true,

          title: const Text(
            'اتجاه القبلة',
            style: TextStyle(
              color:
              Color(0xFF176B5B),
              fontWeight:
              FontWeight.bold,
            ),
          ),

          iconTheme:
          const IconThemeData(
            color:
            Color(0xFF176B5B),
          ),
        ),

        body: SafeArea(
          child: BlocBuilder<
              QiblaBloc,
              QiblaState>(
            builder:
                (context, state) {
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
          child:
          CircularProgressIndicator(
            color:
            Color(0xFF176B5B),
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
      padding:
      const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          const Text(
            'وجّه هاتفك نحو القبلة',
            style: TextStyle(
              fontSize: 22,
              fontWeight:
              FontWeight.bold,
              color:
              Color(0xFF176B5B),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'حرّك الهاتف حتى يشير السهم '
                'إلى اتجاه الكعبة',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 30),

          QiblaCompass(
            qiblaDirection:
            qibla.qiblaDirection,
            heading: _heading,
          ),

          const SizedBox(height: 25),

          if (_heading != null)
            Text(
              'اتجاه الهاتف: '
                  '${_heading!.toStringAsFixed(0)}°',
              style:
              const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

          const SizedBox(height: 20),

          QiblaInfoCard(
            qiblaDirection:
            qibla.qiblaDirection,
            latitude:
            qibla.latitude,
            longitude:
            qibla.longitude,
          ),

          const SizedBox(height: 20),

          _buildHint(),
        ],
      ),
    );
  }

  Widget _buildHint() {
    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
        const Color(0xFF176B5B)
            .withOpacity(0.08),
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color:
            Color(0xFF176B5B),
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'للحصول على قراءة أدق، أبعد '
                  'الهاتف عن الأجهزة المعدنية '
                  'وحركه بشكل رقم 8 لمعايرة البوصلة.',
              style: TextStyle(
                fontSize: 13,
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
        padding:
        const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off_rounded,
              size: 70,
              color:
              Color(0xFF176B5B),
            ),

            const SizedBox(height: 20),

            Text(
              state.errorMessage ??
                  'حدث خطأ',
              textAlign:
              TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                context
                    .read<QiblaBloc>()
                    .add(
                  const QiblaRetry(),
                );
              },
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(
                    0xFF176B5B),
                foregroundColor:
                Colors.white,
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                      14),
                ),
              ),
              child:
              const Text(
                'إعادة المحاولة',
              ),
            ),
          ],
        ),
      ),
    );
  }
}