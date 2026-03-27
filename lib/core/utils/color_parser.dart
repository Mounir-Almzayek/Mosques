import 'package:flutter/material.dart' show Color;

/// Parses a hex color string (with or without `#`, 6 or 8 characters)
/// into a [Color]. Returns [fallback] on invalid input.
///
/// Supported formats:
/// - `#RRGGBB` → treated as fully opaque (`FFRRGGBB`)
/// - `#AARRGGBB`
/// - Same without the `#` prefix
Color parseColorHex(String? hexString, Color fallback) {
  if (hexString == null || hexString.isEmpty) return fallback;
  var hex = hexString.replaceFirst('#', '').trim();
  if (hex.length == 6) {
    hex = 'FF$hex';
  } else if (hex.length != 8) {
    return fallback;
  }
  try {
    return Color(int.parse(hex, radix: 16));
  } catch (_) {
    return fallback;
  }
}
