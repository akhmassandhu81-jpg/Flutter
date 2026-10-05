import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryBackground = Color(0xFF0A0E27);
  static const Color secondaryBackground = Color(0xFF1A1F3A);
  
  // Accent colors
  static const Color accentBlue = Color(0xFF4A9FFF);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF06B6D4);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB4B4B4);
  static const Color textTertiary = Color(0xFF6B7280);
  
  // UI elements
  static const Color cardBackground = Color(0xFF1E2339);
  static const Color borderColor = Color(0xFF2D3348);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentBlue, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [primaryBackground, secondaryBackground],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
