import 'dart:math';

import 'package:flutter/material.dart';

class QiblaCompass extends StatelessWidget {
  final double qiblaDirection;
  final double? heading;

  const QiblaCompass({
    super.key,
    required this.qiblaDirection,
    required this.heading,
  });

  @override
  Widget build(BuildContext context) {
    if (heading == null) {
      return const SizedBox(
        width: 300,
        height: 300,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF176B5B),
          ),
        ),
      );
    }

    final angle =
        (qiblaDirection - heading!) * pi / 180;

    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color:
                  Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: CustomPaint(
              painter: CompassPainter(),
            ),
          ),

          Transform.rotate(
            angle: angle,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration:
                  const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF176B5B),
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                ),

                const SizedBox(height: 5),

                CustomPaint(
                  size:
                  const Size(35, 100),
                  painter: ArrowPainter(),
                ),
              ],
            ),
          ),

          Container(
            width: 14,
            height: 14,
            decoration:
            const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class CompassPainter
    extends CustomPainter {
  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      center,
      radius - 5,
      paint,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final directions = [
      ['N', 0.0],
      ['E', pi / 2],
      ['S', pi],
      ['W', 3 * pi / 2],
    ];

    for (final direction in directions) {
      final text =
      direction[0] as String;

      final angle =
      direction[1] as double;

      final x = center.dx +
          cos(angle - pi / 2) *
              (radius - 30);

      final y = center.dy +
          sin(angle - pi / 2) *
              (radius - 30);

      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: text == 'N'
              ? const Color(0xFF176B5B)
              : Colors.grey.shade700,
        ),
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          x - textPainter.width / 2,
          y - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}

class ArrowPainter
    extends CustomPainter {
  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color = const Color(0xFF176B5B)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(
        size.width,
        size.height * 0.35,
      )
      ..lineTo(
        size.width / 2,
        size.height * 0.25,
      )
      ..lineTo(
        0,
        size.height * 0.35,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}