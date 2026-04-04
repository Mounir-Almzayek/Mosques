import 'package:equatable/equatable.dart';

import '../../../core/enums/app_numeral_format.dart';
import 'design_background_settings.dart';
import 'font_size_settings.dart';
import 'design_color_settings.dart';

/// Top-level visual settings for the display screen.
/// Groups related properties into sub-models for better architecture.
class DesignSettingsModel extends Equatable {
  /// Background configuration (Image vs Color).
  final DesignBackgroundSettings background;

  /// Font sizes for all components.
  final FontSizeSettings fontSizes;

  /// Colors for all components.
  final DesignColorSettings colors;

  final double tickerSpeed;
  final double stripSpeed;
  final AppNumeralFormat numeralFormat;
  final String fontFamily;

  const DesignSettingsModel({
    this.background = const DesignBackgroundSettings(),
    this.fontSizes = const FontSizeSettings(),
    this.colors = const DesignColorSettings(),
    this.tickerSpeed = 1.0,
    this.stripSpeed = 1.0,
    this.numeralFormat = AppNumeralFormat.english,
    this.fontFamily = 'Beiruti',
  });

  factory DesignSettingsModel.fromMap(Map<String, dynamic> map) {
    return DesignSettingsModel(
      background: DesignBackgroundSettings.fromMap(map),
      fontSizes: FontSizeSettings.fromMap(map),
      colors: DesignColorSettings.fromMap(map),
      tickerSpeed: (map['ticker_speed'] ?? 1.0).toDouble(),
      stripSpeed: (map['strip_speed'] ?? 1.0).toDouble(),
      numeralFormat: AppNumeralFormat.fromCode(map['numeral_format'] ?? 'en'),
      fontFamily: map['font_family'] ?? 'Beiruti',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ...background.toMap(),
      ...fontSizes.toMap(),
      ...colors.toMap(),
      'ticker_speed': tickerSpeed,
      'strip_speed': stripSpeed,
      'numeral_format': numeralFormat.code,
      'font_family': fontFamily,
    };
  }

  DesignSettingsModel copyWith({
    DesignBackgroundSettings? background,
    FontSizeSettings? fontSizes,
    DesignColorSettings? colors,
    double? tickerSpeed,
    double? stripSpeed,
    AppNumeralFormat? numeralFormat,
    String? fontFamily,
  }) {
    return DesignSettingsModel(
      background: background ?? this.background,
      fontSizes: fontSizes ?? this.fontSizes,
      colors: colors ?? this.colors,
      tickerSpeed: tickerSpeed ?? this.tickerSpeed,
      stripSpeed: stripSpeed ?? this.stripSpeed,
      numeralFormat: numeralFormat ?? this.numeralFormat,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  @override
  List<Object?> get props => [
    background,
    fontSizes,
    colors,
    tickerSpeed,
    stripSpeed,
    numeralFormat,
    fontFamily,
  ];
}
