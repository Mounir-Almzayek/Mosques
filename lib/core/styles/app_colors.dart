import 'package:flutter/material.dart';

/// App color palette: deep teal-green brand, warm neutral surfaces.
abstract final class AppColors {
  // —— Brand teal ——
  static const Color primaryDark = Color(0xFF2A3A39);
  static const Color primary = Color(0xFF384C4B);
  static const Color primaryLight = Color(0xFF4D6362);
  static const Color primarySurface = Color(0xFFA8BFBE);
  static const Color primaryWhisper = Color(0xFFDCE8E7);

  // —— Warm surfaces ——
  static const Color creamWhite = Color(0xFFFFFBF7);
  static const Color pearlMist = Color(0xFFF7F3ED);

  /// Alias for primary brand color
  static const Color primaryStart = primaryLight;
  static const Color primaryEnd = primaryDark;

  // —— Text ——
  static const Color primaryText = Color(0xFF2A2A2A);
  static const Color secondaryText = Color(0xFF5E5E5E);
  static const Color mutedForeground = secondaryText;
  static const Color foreground = primaryText;

  // —— Backgrounds & cards ——
  static const Color background = pearlMist;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = surface;
  static const Color brightWhite = surface;
  static const Color muted = primaryWhisper;

  // —— Borders & inputs ——
  static const Color border = Color(0xFFD4DBD9);
  static const Color input = Color(0xFFB8C4C3);

  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // —— Focus ——
  /// High-contrast ring used to mark the focused control for TV remote /
  /// keyboard navigation. Brightened brand teal so it reads at a distance.
  static const Color focusRing = Color(0xFF2DD4BF);

  // —— States ——
  static const Color error = Color(0xFFC53030);
  static const Color success = Color(0xFF2D6A4F);
  static const Color warning = Color(0xFFB8860B);

  // —— Gradients ——
  static const LinearGradient loginBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), creamWhite, pearlMist],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0x00384C4B), primarySurface, Color(0x00384C4B)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0x1A384C4B), Color(0x26384C4B)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
