import 'package:flutter/material.dart';

/// App Color Palette - Pink & Orange Theme
class AppColors {
  // Primary Colors
  static const Color primaryPink = Color(0xFFFF6B9D);
  static const Color secondaryOrange = Color(0xFFFF9A56);
  
  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static Color grey = Colors.grey.shade600;
  static Color lightGrey = Colors.grey.shade300;
  
  // Background Colors
  static Color background = Colors.grey.shade50;
  static Color cardBackground = Colors.white;
}

/// App Text Styles
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryPink,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
  );
  
  static TextStyle bodyGrey = TextStyle(
    fontSize: 16,
    color: AppColors.grey,
  );
}
