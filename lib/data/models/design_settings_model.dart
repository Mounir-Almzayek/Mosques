import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show Color;

import '../../core/enums/display_background_preset.dart';

/// Visual settings for the display screen.
/// [backgroundValue] — [DisplayBackgroundPreset.storageId] for the full-screen image.
/// [prayerOverlayColor] ARGB hex (e.g. `#80143B4E`) — للبطاقات والـ SVG.
class DesignSettingsModel extends Equatable {
  final String backgroundValue;
  final String primaryColor;
  final String secondaryColor;
  final String prayerOverlayColor;
  final double baseFontSize;

  const DesignSettingsModel({
    required this.backgroundValue,
    required this.primaryColor,
    required this.secondaryColor,
    required this.prayerOverlayColor,
    required this.baseFontSize,
  });

  static const Color _defaultPrimary = Color(0xFF143B4E);
  static const Color _defaultSecondary = Color(0xFFF3EEDC);

  static Color _parseColorHex(String? hexString, Color fallback) {
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

  /// لون أساسي جاهز للواجهة (من [primaryColor] كسلسلة hex).
  Color get primaryColorValue => _parseColorHex(primaryColor, _defaultPrimary);

  /// لون ثانوي جاهز للواجهة (من [secondaryColor]).
  Color get secondaryColorValue => _parseColorHex(secondaryColor, _defaultSecondary);

  /// لون بطاقات الصلاة / الـ SVG (من [prayerOverlayColor]).
  Color get prayerCardColorValue => _parseColorHex(prayerOverlayColor, _defaultSecondary);

  factory DesignSettingsModel.fromMap(Map<String, dynamic> map) {
    return DesignSettingsModel(
      backgroundValue: DisplayBackgroundPreset.normalizeStoredId(
        map['background_value']?.toString(),
      ),
      primaryColor: map['primary_color']?.toString() ?? '#FFFFFF',
      secondaryColor: map['secondary_color']?.toString() ?? '#CCCCCC',
      prayerOverlayColor: map['prayer_overlay_color']?.toString() ?? '#66143B4E',
      baseFontSize: (map['base_font_size'] ?? 16.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'background_type': 'color',
      'background_value': backgroundValue,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'prayer_overlay_color': prayerOverlayColor,
      'base_font_size': baseFontSize,
    };
  }

  DesignSettingsModel copyWith({
    String? backgroundValue,
    String? primaryColor,
    String? secondaryColor,
    String? prayerOverlayColor,
    double? baseFontSize,
  }) {
    return DesignSettingsModel(
      backgroundValue: backgroundValue ?? this.backgroundValue,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      prayerOverlayColor: prayerOverlayColor ?? this.prayerOverlayColor,
      baseFontSize: baseFontSize ?? this.baseFontSize,
    );
  }

  @override
  List<Object?> get props => [
        backgroundValue,
        primaryColor,
        secondaryColor,
        prayerOverlayColor,
        baseFontSize,
      ];
}
