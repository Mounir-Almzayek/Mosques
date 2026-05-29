import 'package:flutter/material.dart';

import '../../enums/feedback/snackbar_type.dart';
import '../../styles/app_colors.dart';

/// Visual identity for a single snackbar type.
///
/// The redesigned toast keeps a constant warm ivory surface and soft-black
/// text across all types; only the [accent] (rail, icon, progress) and the
/// leading [icon] change. This keeps the component cohesive and lets the
/// semantic colour read as a sharp accent rather than tinting the whole card.
class SnackbarPalette {
  /// Semantic colour: drives the leading rail, icon chip, and countdown bar.
  final Color accent;

  /// Glyph shown in the rounded icon chip.
  final IconData icon;

  const SnackbarPalette({required this.accent, required this.icon});

  /// Shared warm surface — matches the app's cream identity.
  static const Color surface = AppColors.creamWhite;

  /// Message text colour (strong neutral for readability on [surface]).
  static const Color text = AppColors.primaryText;

  factory SnackbarPalette.forType(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return const SnackbarPalette(
          accent: AppColors.success,
          icon: Icons.check_rounded,
        );
      case SnackbarType.error:
        return const SnackbarPalette(
          accent: AppColors.error,
          icon: Icons.error_outline_rounded,
        );
      case SnackbarType.warning:
        return const SnackbarPalette(
          accent: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        );
      case SnackbarType.info:
        return const SnackbarPalette(
          accent: AppColors.primary,
          icon: Icons.info_outline_rounded,
        );
    }
  }
}
