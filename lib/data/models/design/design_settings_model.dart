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

  final int preAdhanMinutes;
  final int adhanMomentDurationSeconds;
  final int religiousContentWaitSeconds;
  final int religiousContentDisplaySeconds;

  /// Scale factor for prayer cards on the display screen (0.5–2.0).
  final double prayerCardScale;

  const DesignSettingsModel({
    this.background = const DesignBackgroundSettings(),
    this.fontSizes = const FontSizeSettings(),
    this.colors = const DesignColorSettings(),
    this.tickerSpeed = 1.0,
    this.stripSpeed = 1.0,
    this.numeralFormat = AppNumeralFormat.english,
    this.fontFamily = 'Beiruti',
    this.preAdhanMinutes = 5,
    this.adhanMomentDurationSeconds = 60,
    this.religiousContentWaitSeconds = 120,
    this.religiousContentDisplaySeconds = 30,
    this.prayerCardScale = 1.0,
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
      preAdhanMinutes: map['pre_adhan_minutes'] ?? 5,
      adhanMomentDurationSeconds: map['adhan_moment_duration_seconds'] ?? 60,
      religiousContentWaitSeconds: map['religious_content_wait_seconds'] ?? 120,
      religiousContentDisplaySeconds: map['religious_content_display_seconds'] ?? 30,
      prayerCardScale: (map['prayer_card_scale'] ?? 1.0).toDouble(),
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
      'pre_adhan_minutes': preAdhanMinutes,
      'adhan_moment_duration_seconds': adhanMomentDurationSeconds,
      'religious_content_wait_seconds': religiousContentWaitSeconds,
      'religious_content_display_seconds': religiousContentDisplaySeconds,
      'prayer_card_scale': prayerCardScale,
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
    int? preAdhanMinutes,
    int? adhanMomentDurationSeconds,
    int? religiousContentWaitSeconds,
    int? religiousContentDisplaySeconds,
    double? prayerCardScale,
  }) {
    return DesignSettingsModel(
      background: background ?? this.background,
      fontSizes: fontSizes ?? this.fontSizes,
      colors: colors ?? this.colors,
      tickerSpeed: tickerSpeed ?? this.tickerSpeed,
      stripSpeed: stripSpeed ?? this.stripSpeed,
      numeralFormat: numeralFormat ?? this.numeralFormat,
      fontFamily: fontFamily ?? this.fontFamily,
      preAdhanMinutes: preAdhanMinutes ?? this.preAdhanMinutes,
      adhanMomentDurationSeconds: adhanMomentDurationSeconds ?? this.adhanMomentDurationSeconds,
      religiousContentWaitSeconds: religiousContentWaitSeconds ?? this.religiousContentWaitSeconds,
      religiousContentDisplaySeconds: religiousContentDisplaySeconds ?? this.religiousContentDisplaySeconds,
      prayerCardScale: prayerCardScale ?? this.prayerCardScale,
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
    preAdhanMinutes,
    adhanMomentDurationSeconds,
    religiousContentWaitSeconds,
    religiousContentDisplaySeconds,
    prayerCardScale,
  ];
}
