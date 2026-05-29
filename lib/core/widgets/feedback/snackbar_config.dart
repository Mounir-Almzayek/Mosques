import 'package:flutter/material.dart';

/// Snackbar Configuration
class SnackbarConfig {
  final Duration duration;
  final SnackBarBehavior behavior;
  final EdgeInsets margin;
  final double? width;
  final bool showCloseButton;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const SnackbarConfig({
    this.duration = const Duration(seconds: 3),
    this.behavior = SnackBarBehavior.floating,
    this.margin = const EdgeInsets.all(16),
    this.width,
    this.showCloseButton = false,
    this.onTap,
    this.actionLabel,
    this.onActionTap,
  });
}
