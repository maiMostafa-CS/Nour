
import 'package:flutter/material.dart';

import '../../constants/tasbih_data.dart';

class EditTargetDialog extends StatefulWidget {
  final int currentTarget;

  const EditTargetDialog({super.key, required this.currentTarget});

  @override
  State<EditTargetDialog> createState() => _EditTargetDialogState();
}

class _EditTargetDialogState extends State<EditTargetDialog> {
  late final TextEditingController _ctrl;
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentTarget.toString());
    _selected = widget.currentTarget;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_ctrl.text.trim());
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال عدد صحيح أكبر من صفر'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Row(
        children: [
          Icon(Icons.tune, color: Colors.tealAccent),
          SizedBox(width: 8),
          Text('تعديل العدد المستهدف',
              style: TextStyle(color: Colors.black, fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('اختر عدداً سريعاً:',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TasbihData.targetPresets.map((preset) {
                final isSelected = _selected == preset;
                return ChoiceChip(
                  label: Text(
                    preset.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.tealAccent.shade700,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.tealAccent
                        : Colors.white.withOpacity(0.15),
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selected = preset;
                      _ctrl.text = preset.toString();
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 22),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'أو أدخل عدداً مخصصاً',
                labelStyle: const TextStyle(color: Colors.white54),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear,
                      color: Colors.white38, size: 18),
                  onPressed: () => setState(() => _ctrl.clear()),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.tealAccent),
                ),
              ),
              onChanged: (v) => setState(() => _selected = int.tryParse(v) ?? 0),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check),
          label: const Text('حفظ'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent.shade700,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}