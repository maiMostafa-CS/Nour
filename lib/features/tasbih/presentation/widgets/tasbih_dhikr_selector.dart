import 'package:flutter/material.dart';

import '../../models/tasbih_model.dart';

class TasbihDhikrSelector extends StatelessWidget {
  final int selectedIndex;
  final List<TasbihDhikr> adhkar;
  final ValueChanged<int> onSelect;

  const TasbihDhikrSelector({
    super.key,
    required this.selectedIndex,
    required this.adhkar,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: adhkar.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final dhikr = adhkar[index];
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.tealAccent.shade700
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? Colors.tealAccent
                      : Colors.white.withOpacity(0.15),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (dhikr.isCustom)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.person_outline,
                              size: 14, color: Colors.amberAccent),
                        ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: Text(
                          dhikr.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.white70,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dhikr.targetCount} مرة',
                    style: TextStyle(
                      color: selected
                          ? Colors.white.withOpacity(0.9)
                          : Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}