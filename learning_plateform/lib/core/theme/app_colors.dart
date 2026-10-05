import 'package:flutter/material.dart';

/// Central color palette for LMS ARENA.
/// All screens must consume these constants — never hardcode hex values in widgets.
class AppColors {
  AppColors._();

  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const Color primaryBackground   = Color(0xFF080C1E);
  static const Color secondaryBackground = Color(0xFF0E1229);
  static const Color cardBackground      = Color(0xFF111528);
  static const Color cardSurface         = Color(0xFF161B30);
  static const Color inputFill           = Color(0xFF111428);

  // ── Brand accents ──────────────────────────────────────────────────────────
  static const Color accentBlue   = Color(0xFF4A9FFF);
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentCyan   = Color(0xFF06B6D4);
  static const Color accentGreen  = Color(0xFF10B981);
  static const Color accentOrange = Color(0xFFF59E0B);

  // ── Typography ─────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB4B4B4);
  static const Color textTertiary  = Color(0xFF6B7280);
  static const Color textMuted     = Color(0xFF4B5563);

  // ── Borders / dividers ─────────────────────────────────────────────────────
  static const Color borderColor     = Color(0xFF2D3348);
  static const Color borderSubtle    = Color(0xFF1E2339);
  static const Color dividerColor    = Color(0xFF1A1F35);

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentBlue, accentPurple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [accentCyan, accentBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [primaryBackground, secondaryBackground],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [cardBackground, cardSurface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Subject icon backgrounds ───────────────────────────────────────────────
  static const Color mathColor     = Color(0xFF1E3A5F);
  static const Color physicsColor  = Color(0xFF1A2E4A);
  static const Color chemColor     = Color(0xFF1A3830);
  static const Color csColor       = Color(0xFF2D1B4E);
  static const Color bioColor      = Color(0xFF1A3024);
  static const Color engColor      = Color(0xFF3B1F1F);
  static const Color urduColor     = Color(0xFF2D2616);
  static const Color islamColor    = Color(0xFF1F2D1A);
}
