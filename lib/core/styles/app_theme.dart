import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import '../utils/responsive_layout.dart';

/// الثيم الرئيسي للتطبيق — يعتمد على [AppColors] (ذهبي، كريمي، أسود ناعم).
/// استخدم دائماً: `Theme.of(context)` أو `AppTheme.light(context)` في [MaterialApp].
abstract final class AppTheme {
  AppTheme._();

  /// ثيم فاتح واحد (Material 3) متناسق مع هوية المسجد.
  static ThemeData light(
    BuildContext context, {
    String fontFamily = 'Beiruti',
  }) {
    const double globalRadius = 14.0;

    double size(double base) =>
        ResponsiveLayout.adaptiveFontSize(context, base.sp);

    double iSize(double base) =>
        ResponsiveLayout.adaptiveIconSize(context, base.sp);

    final baseTextTheme = TextTheme(
      displayLarge: TextStyle(color: AppColors.primaryText, fontSize: size(57)),
      displayMedium: TextStyle(
        color: AppColors.primaryText,
        fontSize: size(45),
      ),
      displaySmall: TextStyle(color: AppColors.primaryText, fontSize: size(36)),
      headlineLarge: TextStyle(
        color: AppColors.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: size(32),
      ),
      headlineMedium: TextStyle(
        color: AppColors.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: size(28),
      ),
      headlineSmall: TextStyle(
        color: AppColors.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: size(24),
      ),
      titleLarge: TextStyle(
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: size(22),
      ),
      titleMedium: TextStyle(
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: size(16),
      ),
      titleSmall: TextStyle(
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: size(14),
      ),
      bodyLarge: TextStyle(color: AppColors.primaryText, fontSize: size(16)),
      bodyMedium: TextStyle(color: AppColors.primaryText, fontSize: size(14)),
      bodySmall: TextStyle(color: AppColors.secondaryText, fontSize: size(12)),
      labelLarge: TextStyle(color: AppColors.primaryText, fontSize: size(14)),
      labelMedium: TextStyle(
        color: AppColors.secondaryText,
        fontSize: size(12),
      ),
      labelSmall: TextStyle(color: AppColors.secondaryText, fontSize: size(11)),
    );

    // Dynamic Google Font integration
    final textTheme = GoogleFonts.getTextTheme(fontFamily, baseTextTheme);

    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.goldWhisper,
      onSecondary: AppColors.primaryText,
      error: AppColors.error,
      onError: AppColors.brightWhite,
      surface: AppColors.surface,
      onSurface: AppColors.foreground,
      surfaceContainerHighest: AppColors.muted,
      outline: AppColors.border,
      outlineVariant: AppColors.input,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Beiruti',
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: scheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryText,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.primaryText,
          fontSize: size(18),
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.primaryText, size: iSize(24)),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      iconTheme: IconThemeData(color: AppColors.foreground, size: iSize(24)),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(globalRadius),
        ),
        titleTextStyle: TextStyle(
          fontSize: size(20),
          fontWeight: FontWeight.w700,
          color: AppColors.primaryText,
        ),
        contentTextStyle: TextStyle(
          fontSize: size(14),
          color: AppColors.primaryText,
          height: 1.4,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryText,
        contentTextStyle: TextStyle(
          fontSize: size(14),
          color: AppColors.brightWhite,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        textStyle: TextStyle(fontSize: size(14), color: AppColors.primaryText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(globalRadius),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.brightWhite,
        elevation: 4,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.brightWhite,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(globalRadius),
          ),
          textStyle: TextStyle(fontSize: size(16), fontWeight: FontWeight.bold),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.creamWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.input),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.input),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: TextStyle(
          color: AppColors.secondaryText.withValues(alpha: 0.65),
          fontSize: size(14),
        ),
        labelStyle: TextStyle(
          color: AppColors.secondaryText,
          fontSize: size(14),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// توافق مع الكود القديم — يفضّل استخدام [AppTheme.light].
@Deprecated('Use AppTheme.light(context) instead')
ThemeData appThemeData(BuildContext context) => AppTheme.light(context);
