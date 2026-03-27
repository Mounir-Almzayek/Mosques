import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Utility to dynamically load fonts from Google Fonts with a local fallback.
abstract final class AppFontLoader {
  AppFontLoader._();

  /// Gets a [TextStyle] applying the requested [fontFamily] from Google Fonts.
  /// Falls back to 'Beiruti' or the system default if not found.
  static TextStyle getStyle(String fontFamily, {TextStyle? baseStyle}) {
    try {
      // Logic to resolve Google Font by name string.
      return GoogleFonts.getFont(
        fontFamily,
        textStyle: baseStyle,
      );
    } catch (_) {
      // Fallback to Beiruti or local font if Google Font loading fails or not found.
      return (baseStyle ?? const TextStyle()).copyWith(fontFamily: 'Beiruti');
    }
  }

  /// App-wide theme data factory using the dynamic font.
  static ThemeData getTheme(String fontFamily) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily, // Global default font family
      textTheme: GoogleFonts.getTextTheme(
        fontFamily,
        const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Beiruti'), // Fallback for specific styles if needed
          headlineMedium: TextStyle(fontFamily: 'Beiruti'),
        ),
      ),
    );
  }
}
