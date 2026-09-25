import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../bloc/azkar_state.dart';

class AzkarItemsView extends StatefulWidget {
  final AzkarItemsLoaded state;

  const AzkarItemsView({
    super.key,
    required this.state,
  });

  @override
  State<AzkarItemsView> createState() => _AzkarItemsViewState();
}

class _AzkarItemsViewState extends State<AzkarItemsView> {
  final Set<int> _hiddenItems = {};
  final Map<int, int> _remaining = {};
  final List<int> _history = [];

  void _onItemTap(dynamic item) {
    setState(() {
      final id = item.id;

      _remaining[id] ??= item.count;
      _remaining[id] = _remaining[id]! - 1;

      _history.add(id);

      if (_remaining[id]! <= 0) {
        _hiddenItems.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = widget.state.items
        .where((item) => !_hiddenItems.contains(item.id))
        .toList();

    if (visibleItems.isEmpty) {
      return const Center(
        child: Text(
          'تم الانتهاء من الأذكار',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visibleItems.length,
      itemBuilder: (context, index) {
        final item = visibleItems[index];

        final remaining =
            _remaining[item.id] ?? item.count;

        return GestureDetector(
          onTap: () => _onItemTap(item),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFCF5D7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF8B5A2B).withOpacity(0.25),
              ),
            ),
            child: Column(
              children: [
                Text(
                  item.text,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 2,
                  ),
                ),

                const SizedBox(height: 12),

                if (item.count > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5A2B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$remaining',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}