import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Utility to dynamically load fonts from Google Fonts with a local fallback.
abstract final class AppFontLoader {
  AppFontLoader._();

  /// Gets a [TextStyle] applying the requested [fontFamily] from Google Fonts.
  /// Falls back to 'Beiruti' or the system default if not found.
  static TextStyle getStyle(String fontFamily, {TextStyle? baseStyle}) {
    try {
      return GoogleFonts.getFont(
        fontFamily,
        textStyle: baseStyle,
      );
    } catch (_) {
      return (baseStyle ?? const TextStyle()).copyWith(fontFamily: 'Beiruti');
    }
  }
}
