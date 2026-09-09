import 'package:flutter/material.dart';

class QiblaInfoCard extends StatelessWidget {
  final double qiblaDirection;
  final double latitude;
  final double longitude;

  const QiblaInfoCard({
    super.key,
    required this.qiblaDirection,
    required this.latitude,
    required this.longitude,
  });

  String get directionText {
    if (qiblaDirection >= 337.5 ||
        qiblaDirection < 22.5) {
      return 'شمال';
    }

    if (qiblaDirection < 67.5) {
      return 'شمال شرق';
    }

    if (qiblaDirection < 112.5) {
      return 'شرق';
    }

    if (qiblaDirection < 157.5) {
      return 'جنوب شرق';
    }

    if (qiblaDirection < 202.5) {
      return 'جنوب';
    }

    if (qiblaDirection < 247.5) {
      return 'جنوب غرب';
    }

    if (qiblaDirection < 292.5) {
      return 'غرب';
    }

    return 'شمال غرب';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color:
                  const Color(0xFF176B5B)
                      .withOpacity(0.1),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color:
                  Color(0xFF176B5B),
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'اتجاه القبلة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),

              Text(
                '${qiblaDirection.toStringAsFixed(0)}°',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  Color(0xFF176B5B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Divider(),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.navigation_rounded,
                size: 20,
                color: Colors.grey,
              ),

              const SizedBox(width: 8),

              Text(
                directionText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const Spacer(),

              Text(
                '${latitude.toStringAsFixed(4)}, '
                    '${longitude.toStringAsFixed(4)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}