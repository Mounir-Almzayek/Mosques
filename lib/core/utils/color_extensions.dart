import 'package:flutter/material.dart';

/// Alpha scaling equivalent to the deprecated `withOpacity` (multiply alpha channel).
extension ColorOpacityCompat on Color {
  Color withOpacityCompat(double opacity) {
    return withValues(alpha: (a * opacity).clamp(0.0, 1.0));
  }
}
