import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show Color, Colors;

import '../../core/enums/app_numeral_format.dart';
import '../../core/enums/display_background_preset.dart';
import '../../core/utils/color_parser.dart';

/// Visual and behavioral settings for the display screen.
class DesignSettingsModel extends Equatable {
  final String backgroundValue;
  final String primaryColor;
  final String secondaryColor;
  final String prayerOverlayColor;
  final String activeCardColor;
  final String activeCardTextColor;
  final String inactiveCardTextColor;
  final double baseFontSize;

  /// Speed of the bottom ticker (1.0 = normal, higher = faster).
  final double tickerSpeed;

  /// Forced numeral format for the entire app.
  final AppNumeralFormat numeralFormat;

  /// Google Font name or custom font family.
  final String fontFamily;

  const DesignSettingsModel({
    required this.backgroundValue,
    required this.primaryColor,
    required this.secondaryColor,
    required this.prayerOverlayColor,
    required this.activeCardColor,
    required this.activeCardTextColor,
    required this.inactiveCardTextColor,
    required this.baseFontSize,
    this.tickerSpeed = 1.0,
    this.numeralFormat = AppNumeralFormat.english,
    this.fontFamily = 'Beiruti',
  });

  static const Color _defaultPrimary = Color(0xFF143B4E);
  static const Color _defaultSecondary = Color(0xFFF3EEDC);

  /// UI-ready primary color parsed from the hex string.
  /// (Renamed in UI to Clock and Time color)
  Color get primaryColorValue => parseColorHex(primaryColor, _defaultPrimary);

  /// UI-ready secondary color parsed from the hex string.
  /// (Renamed in UI to Ticker Bar Color)
  Color get secondaryColorValue =>
      parseColorHex(secondaryColor, _defaultSecondary);

  /// UI-ready color for inactive prayer cards.
  Color get prayerCardColorValue =>
      parseColorHex(prayerOverlayColor, _defaultSecondary);

  /// UI-ready color for the active prayer card (the one with the countdown).
  Color get activeCardColorValue => 
      parseColorHex(activeCardColor, _defaultPrimary);

  /// UI-ready text color for the active prayer card.
  Color get activeCardTextColorValue => 
      parseColorHex(activeCardTextColor, Colors.white);

  /// UI-ready text color for inactive cards and the hadith/spiritual section.
  Color get inactiveCardTextColorValue =>
      parseColorHex(inactiveCardTextColor, _defaultPrimary);

  factory DesignSettingsModel.fromMap(Map<String, dynamic> map) {
    return DesignSettingsModel(
      backgroundValue: DisplayBackgroundPreset.normalizeStoredId(
        map['background_value']?.toString(),
      ),
      primaryColor: map['primary_color']?.toString() ?? '#FFFFFF',
      secondaryColor: map['secondary_color']?.toString() ?? '#CCCCCC',
      prayerOverlayColor:
          map['prayer_overlay_color']?.toString() ?? '#66143B4E',
      activeCardColor: map['active_card_color']?.toString() ?? '#143B4E',
      activeCardTextColor: map['active_card_text_color']?.toString() ?? '#FFFFFF',
      inactiveCardTextColor: map['inactive_card_text_color']?.toString() ?? '#143B4E',
      baseFontSize: (map['base_font_size'] ?? 16.0).toDouble(),
      tickerSpeed: (map['ticker_speed'] ?? 1.0).toDouble(),
      numeralFormat: AppNumeralFormat.fromCode(map['numeral_format'] ?? 'en'),
      fontFamily: map['font_family'] ?? 'Beiruti',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'background_type': 'color',
      'background_value': backgroundValue,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'prayer_overlay_color': prayerOverlayColor,
      'active_card_color': activeCardColor,
      'active_card_text_color': activeCardTextColor,
      'inactive_card_text_color': inactiveCardTextColor,
      'base_font_size': baseFontSize,
      'ticker_speed': tickerSpeed,
      'numeral_format': numeralFormat.code,
      'font_family': fontFamily,
    };
  }

  DesignSettingsModel copyWith({
    String? backgroundValue,
    String? primaryColor,
    String? secondaryColor,
    String? prayerOverlayColor,
    String? activeCardColor,
    String? activeCardTextColor,
    String? inactiveCardTextColor,
    double? baseFontSize,
    double? tickerSpeed,
    AppNumeralFormat? numeralFormat,
    String? fontFamily,
  }) {
    return DesignSettingsModel(
      backgroundValue: backgroundValue ?? this.backgroundValue,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      prayerOverlayColor: prayerOverlayColor ?? this.prayerOverlayColor,
      activeCardColor: activeCardColor ?? this.activeCardColor,
      activeCardTextColor: activeCardTextColor ?? this.activeCardTextColor,
      inactiveCardTextColor: inactiveCardTextColor ?? this.inactiveCardTextColor,
      baseFontSize: baseFontSize ?? this.baseFontSize,
      tickerSpeed: tickerSpeed ?? this.tickerSpeed,
      numeralFormat: numeralFormat ?? this.numeralFormat,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  @override
  List<Object?> get props => [
    backgroundValue,
    primaryColor,
    secondaryColor,
    prayerOverlayColor,
    activeCardColor,
    activeCardTextColor,
    inactiveCardTextColor,
    baseFontSize,
    tickerSpeed,
    numeralFormat,
    fontFamily,
  ];
}
