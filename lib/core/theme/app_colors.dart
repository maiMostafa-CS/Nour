// core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // الأخضر الإسلامي الأساسي
  static const Color deepGreen = Color(0xFF0E4D3E);
  static const Color emeraldGreen = Color(0xFF176B5B);
  static const Color softGreen = Color(0xFF1B5E4A);

  // الذهبي الإسلامي
  static const Color gold = Color(0xFFD4AF37);
  static const Color softGold = Color(0xFFE8C874);
  static const Color lightGold = Color(0xFFF4E4B8);

  // الخلفيات الكريمية
  static const Color creamBg = Color(0xFFF5F0E6);
  static const Color softCream = Color(0xFFFAF7EF);
  static const Color cardCream = Color(0xFFF3F0E9);

  // النصوص
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color mediumText = Color(0xFF4A4A4A);
  static const Color lightText = Color(0xFF8A8A8A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [emeraldGreen, deepGreen],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softGold, gold],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softCream, creamBg],
  );
}