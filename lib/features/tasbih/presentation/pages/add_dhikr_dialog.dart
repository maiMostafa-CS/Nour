// lib/features/tasbih/widgets/add_dhikr_dialog.dart

import 'package:flutter/material.dart';

import '../../constants/tasbih_data.dart';

class AddDhikrDialog extends StatefulWidget {
  const AddDhikrDialog({super.key});

  @override
  State<AddDhikrDialog> createState() => _AddDhikrDialogState();
}

class _AddDhikrDialogState extends State<AddDhikrDialog> {
  final _formKey = GlobalKey<FormState>();
  final _textCtrl = TextEditingController();
  final _virtueCtrl = TextEditingController();
  final _targetCtrl = TextEditingController(text: '100');
  int _selectedTarget = 100;

  @override
  void dispose() {
    _textCtrl.dispose();
    _virtueCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, {
      'text': _textCtrl.text.trim(),
      'virtue': _virtueCtrl.text.trim(),
      'targetCount': int.tryParse(_targetCtrl.text.trim()) ?? 100,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Row(
        children: [
          Icon(Icons.add_circle_outline, color: Colors.tealAccent),
          SizedBox(width: 8),
          Text('إضافة ذكر جديد', style: TextStyle(color: Colors.white)),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _textCtrl,
                maxLines: 3,
                minLines: 1,
                style: const TextStyle(color: Colors.white),
                textDirection: TextDirection.rtl,
                decoration: _decoration('نص الذكر *', Icons.text_fields),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'الرجاء إدخال نص الذكر';
                  }
                  if (v.trim().length < 3) return 'النص قصير جداً';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _virtueCtrl,
                maxLines: 3,
                minLines: 1,
                style: const TextStyle(color: Colors.white),
                textDirection: TextDirection.rtl,
                decoration:
                _decoration('فضل الذكر (اختياري)', Icons.star_border),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text('العدد المستهدف:',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
                decoration: _decoration('عدد مخصص', Icons.numbers),
                onChanged: (v) =>
                    setState(() => _selectedTarget = int.tryParse(v) ?? 0),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'أدخل عدداً صحيحاً موجباً';
                  return null;
                },
              ),
            ],
          ),
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
          label: const Text('إضافة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent.shade700,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  InputDecoration _decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: Colors.tealAccent),
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
    );
  }
}