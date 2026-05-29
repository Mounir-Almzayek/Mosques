import 'package:flutter/material.dart';

import '../../enums/feedback/snackbar_type.dart';
import '../../styles/app_colors.dart';

class SnackbarPalette {
  final Color background;
  final Color border;
  final Color text;
  final Color accent;
  final IconData icon;

  const SnackbarPalette({
    required this.background,
    required this.border,
    required this.text,
    required this.accent,
    required this.icon,
  });

  factory SnackbarPalette.forType(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return const SnackbarPalette(
          background: Color(0xFFF4FBF7),
          border: Color(0xFFCFE9DA),
          text: Color(0xFF214E3C),
          accent: AppColors.success,
          icon: Icons.check_rounded,
        );
      case SnackbarType.error:
        return const SnackbarPalette(
          background: Color(0xFFFFF5F4),
          border: Color(0xFFF2CFCA),
          text: Color(0xFF7F2B26),
          accent: AppColors.error,
          icon: Icons.error_outline_rounded,
        );
      case SnackbarType.warning:
        return const SnackbarPalette(
          background: Color(0xFFFFFAF1),
          border: Color(0xFFEEDFB2),
          text: Color(0xFF7B5A12),
          accent: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        );
      case SnackbarType.info:
        return const SnackbarPalette(
          background: Color(0xFFFFFAF1),
          border: Color(0xFFE7D3A0),
          text: Color(0xFF6C5110),
          accent: AppColors.primary,
          icon: Icons.info_outline_rounded,
        );
    }
  }
}
