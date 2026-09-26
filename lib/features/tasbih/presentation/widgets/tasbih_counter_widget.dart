import 'package:flutter/material.dart';

class TasbihCounterWidget extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const TasbihCounterWidget({
    super.key,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: enabled
              ? LinearGradient(
            colors: [
              Colors.tealAccent.shade700,
              Colors.teal.shade900,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [Colors.grey.shade800, Colors.grey.shade900],
          ),
          boxShadow: enabled
              ? [
            BoxShadow(
              color: Colors.tealAccent.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ]
              : null,
        ),
        child: Icon(
          enabled ? Icons.touch_app : Icons.check_circle,
          color: Colors.white,
          size: 50,
        ),
      ),
    );
  }
}