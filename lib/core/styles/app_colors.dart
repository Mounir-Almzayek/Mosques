import 'package:flutter/material.dart';

/// لوحة ألوان التطبيق الإسلامية: كريمي/أبيض، ذهبي فاخر، أسود ناعم، وحالات واضحة للنجاح/الخطأ.
abstract final class AppColors {
  // —— ذهبي ——
  static const Color goldDeep = Color(0xFF8B6914);
  static const Color goldRich = Color(0xFFC9A227);
  static const Color goldBright = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE8D5A3);
  static const Color goldWhisper = Color(0xFFF3EAD8);

  // —— أسطح ومحايدات دافئة ——
  static const Color creamWhite = Color(0xFFFFFBF7);
  static const Color pearlMist = Color(0xFFF7F3ED);

  /// لون العلامة والأزرار الرئيسية
  static const Color primary = goldRich;

  /// حواف التدرجات والظلال الخفيفة (بديل اسم قديم: primaryStart / primaryEnd)
  static const Color primaryStart = goldBright;
  static const Color primaryEnd = goldDeep;

  // —— نص ——
  static const Color primaryText = Color(0xFF2A2A2A);
  static const Color secondaryText = Color(0xFF5E5E5E);
  static const Color mutedForeground = secondaryText;
  static const Color foreground = primaryText;

  // —— خلفيات وبطاقات ——
  static const Color background = pearlMist;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = surface;
  static const Color brightWhite = surface;
  static const Color muted = goldWhisper;

  // —— حدود وحقول ——
  static const Color border = Color(0xFFE5DCC8);
  static const Color input = Color(0xFFD4C4B0);

  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // —— حالات (مختصرة، متناسقة مع الواجهة) ——
  static const Color error = Color(0xFFC53030);
  static const Color success = Color(0xFF2D6A4F);
  static const Color warning = Color(0xFFB8860B);

  // —— تدرجات ——
  static const LinearGradient loginBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), creamWhite, pearlMist],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient goldLuxuryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE6CF7A), goldBright, goldRich, goldDeep],
    stops: [0.0, 0.35, 0.7, 1.0],
  );

  static const LinearGradient goldHairlineGradient = LinearGradient(
    colors: [Color(0x00D4AF37), goldLight, Color(0x00D4AF37)],
  );

  /// أزرار وترويسات تستخدم تدرجاً ذهبياً افتراضياً
  static const LinearGradient primaryGradient = goldLuxuryGradient;

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0x1AD4AF37), Color(0x26C9A227)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
