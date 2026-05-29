import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Utility to dynamically load fonts from Google Fonts with a local fallback.
abstract final class AppFontLoader {
  AppFontLoader._();

  /// Font used for Qur'anic verses. Unlike general UI fonts (Beiruti, Cairo…),
  /// it renders the Uthmanic marks — dagger-alef (ـٰ), pause signs (ۚ ۖ ۗ),
  /// alef-wasla (ٱ), small high letters — that otherwise vanish, making a
  /// pasted verse look "stripped".
  ///
  /// 'Scheherazade New' (SIL) covers the full Qur'anic Unicode range and is
  /// monochrome. We deliberately avoid 'Amiri Quran', whose colour glyphs
  /// paint the pause/annotation marks red.
  static const String quranFontFamily = 'Scheherazade New';

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

  /// Qur'an-safe style — use for verse text so Uthmanic marks render.
  static TextStyle getQuranStyle({TextStyle? baseStyle}) =>
      getStyle(quranFontFamily, baseStyle: baseStyle);
}
