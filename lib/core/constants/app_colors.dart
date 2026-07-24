import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ─────────────────────────────────────────────────────────────
  static const Color background      = Color(0xFF070B1E);
  static const Color surface         = Color(0xFF0F1535);
  static const Color surfaceElevated = Color(0xFF182047);
  static const Color surfaceCard     = Color(0xFF1C2551);

  // ── Brand ───────────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF5B7BFF);
  static const Color primaryLight = Color(0xFF8AA0FF);
  static const Color primaryDark  = Color(0xFF3D5FDD);

  // ── Accent ──────────────────────────────────────────────────────────────────
  static const Color accent     = Color(0xFF00E5C0);
  static const Color accentDark = Color(0xFF00B89A);

  // ── Status ──────────────────────────────────────────────────────────────────
  static const Color success   = Color(0xFF00E5C0);
  static const Color successBg = Color(0xFF0A2E28);
  static const Color warning   = Color(0xFFFFBB33);
  static const Color warningBg = Color(0xFF2E2208);
  static const Color error     = Color(0xFFFF4B6E);
  static const Color errorBg   = Color(0xFF2E0A14);
  static const Color pending   = Color(0xFFFFBB33);

  // ── Text ────────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8B91B4);
  static const Color textMuted     = Color(0xFF4A5080);
  static const Color textDisabled  = Color(0xFF2E3460);

  // ── Borders ─────────────────────────────────────────────────────────────────
  static const Color border      = Color(0xFF1E2650);
  static const Color borderLight = Color(0xFF2E3870);
  static const Color borderGlow  = Color(0x405B7BFF);

  // ── Overlays ────────────────────────────────────────────────────────────────
  static const Color overlay           = Color(0x99000000);
  static const Color glassWhite        = Color(0x10FFFFFF);
  static const Color glassWhiteStrong  = Color(0x1AFFFFFF);

  // ── Gradients ───────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5B7BFF), Color(0xFF8B40F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00E5C0), Color(0xFF0066FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFBB33), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFFF4B6E), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0F1535), Color(0xFF070B1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0F2E), Color(0xFF070B1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Category colors
  static const Map<String, Color> categoryColors = {
    'food':          Color(0xFFFF6B35),
    'transport':     Color(0xFF5B7BFF),
    'shopping':      Color(0xFFFF4B6E),
    'entertainment': Color(0xFF8B40F5),
    'health':        Color(0xFF00E5C0),
    'utilities':     Color(0xFFFFBB33),
    'salary':        Color(0xFF00E5C0),
    'investment':    Color(0xFF5B7BFF),
    'transfer':      Color(0xFF8B91B4),
    'other':         Color(0xFF4A5080),
  };
}
