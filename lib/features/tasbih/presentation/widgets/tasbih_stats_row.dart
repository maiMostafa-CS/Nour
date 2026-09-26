import 'package:flutter/material.dart';

class TasbihStatsRow extends StatelessWidget {
  final int completedRounds;
  final int totalCount;
  final int currentIndex;
  final int totalAdhkar;

  const TasbihStatsRow({
    super.key,
    required this.completedRounds,
    required this.totalCount,
    required this.currentIndex,
    required this.totalAdhkar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _statCard(Icons.check_circle_outline, 'الجولات', '$completedRounds'),
        const SizedBox(width: 10),
        _statCard(Icons.tag, 'الإجمالي', '$totalCount'),
        const SizedBox(width: 10),
        _statCard(Icons.list_alt, 'الذكر', '${currentIndex + 1}/$totalAdhkar'),
      ],
    );
  }

  Widget _statCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.tealAccent, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}