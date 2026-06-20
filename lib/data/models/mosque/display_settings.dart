import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show Color;

import '../../../core/enums/app_numeral_format.dart';
import '../../../core/enums/display_background_type.dart';
import '../../../core/utils/color_parser.dart';
import '../../../core/utils/date_parse.dart';

/// Display/design settings — **flat**, 1:1 with backend
/// `DisplaySettingsResponse`. Every storage field matches a backend key.
///
/// Parsed-`Color` and `*Value` getters are convenience accessors only; they add
/// no storage and keep the shape identical to the API contract.
class DisplaySettings extends Equatable {
  final String mosqueId;

  // Background
  final String backgroundType;
  final String backgroundValue;

  // Album / published album
  final List<String> albumImageUrls;
  final String? publishedAlbumUrl;
  final DateTime? publishedAlbumAt;
  final int? publishedAlbumDurationSeconds;
  final String publishedAlbumFit;
  final DateTime? publishedAlbumExpiresAt;
  final bool publishedAlbumActive;

  // Colors (hex strings, exactly as the backend sends them)
  final String primaryColor;
  final String secondaryColor;
  final String activeCardColor;
  final String activeCardTextColor;
  final String inactiveCardColor;
  final String prayerOverlayColor;
  final String inactiveCardTextColor;
  final String countdownTextColor;
  final String countdownBackgroundColor;
  final String alertTextColor;
  final String alertBackgroundColor;

  // Font sizes
  final double clockFontSize;
  final double mosqueInfoFontSize;
  final double prayersFontSize;
  final double announcementsFontSize;
  final double contentFontSize;

  // Motion + layout
  final double tickerSpeed;
  final double stripSpeed;
  final double prayerCardScale;
  final int religiousContentWaitSeconds;
  final int religiousContentDisplaySeconds;

  final AppNumeralFormat numeralFormat;
  final String fontFamily;

  const DisplaySettings({
    this.mosqueId = '',
    this.backgroundType = 'image',
    this.backgroundValue = 'default',
    this.albumImageUrls = const [],
    this.publishedAlbumUrl,
    this.publishedAlbumAt,
    this.publishedAlbumDurationSeconds,
    this.publishedAlbumFit = 'cover',
    this.publishedAlbumExpiresAt,
    this.publishedAlbumActive = false,
    this.primaryColor = '#1B5E3B',
    this.secondaryColor = '#E8F5E9',
    this.activeCardColor = '#C8E6C9',
    this.activeCardTextColor = '#1B5E3B',
    this.inactiveCardColor = '#EFEBE9',
    this.prayerOverlayColor = '#E8F5E9',
    this.inactiveCardTextColor = '#2E7D32',
    this.countdownTextColor = '#FFFFFF',
    this.countdownBackgroundColor = '#143B4E',
    this.alertTextColor = '#FFFFFF',
    this.alertBackgroundColor = '#B3261E',
    this.clockFontSize = 20.0,
    this.mosqueInfoFontSize = 20.0,
    this.prayersFontSize = 20.0,
    this.announcementsFontSize = 20.0,
    this.contentFontSize = 20.0,
    this.tickerSpeed = 1.0,
    this.stripSpeed = 1.0,
    this.prayerCardScale = 1.0,
    this.religiousContentWaitSeconds = 30,
    this.religiousContentDisplaySeconds = 15,
    this.numeralFormat = AppNumeralFormat.english,
    this.fontFamily = 'Beiruti',
  });

  // --- Background helpers ----------------------------------------------------
  DisplayBackgroundType get backgroundTypeKind =>
      DisplayBackgroundType.fromCode(backgroundType);

  Color resolveBackgroundColor(Color fallback) =>
      backgroundTypeKind == DisplayBackgroundType.color
          ? parseColorHex(backgroundValue, fallback)
          : fallback;

  // --- Parsed colors ---------------------------------------------------------
  Color get primaryColorValue => parseColorHex(primaryColor, const Color(0xFF1B5E3B));
  Color get secondaryColorValue => parseColorHex(secondaryColor, const Color(0xFFE8F5E9));
  Color get activeCardColorValue => parseColorHex(activeCardColor, const Color(0xFFC8E6C9));
  Color get activeCardTextColorValue => parseColorHex(activeCardTextColor, const Color(0xFF1B5E3B));
  Color get inactiveCardColorValue => parseColorHex(inactiveCardColor, const Color(0xFFEFEBE9));
  Color get prayerOverlayColorValue => parseColorHex(prayerOverlayColor, const Color(0xFFE8F5E9));
  Color get inactiveCardTextColorValue => parseColorHex(inactiveCardTextColor, const Color(0xFF2E7D32));
  Color get countdownTextColorValue => parseColorHex(countdownTextColor, const Color(0xFFFFFFFF));
  Color get countdownBackgroundColorValue => parseColorHex(countdownBackgroundColor, const Color(0xFF143B4E));
  Color get alertTextColorValue => parseColorHex(alertTextColor, const Color(0xFFFFFFFF));
  Color get alertBackgroundColorValue => parseColorHex(alertBackgroundColor, const Color(0xFFB3261E));

  // --- Compatibility getters for font sizes the backend doesn't model --------
  // The backend has no dedicated alert/countdown font size; reuse the nearest
  // field so display widgets keep a sensible size.
  double get alertsFontSize => announcementsFontSize;
  double get countdownFontSize => clockFontSize;

  factory DisplaySettings.fromJson(Map<String, dynamic> json) {
    double readDouble(String key, double fallback) {
      final value = json[key];
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? fallback;
    }

    int readInt(String key, int fallback) {
      final value = json[key];
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    return DisplaySettings(
      mosqueId: json['mosqueId']?.toString() ?? '',
      backgroundType: json['backgroundType']?.toString() ?? 'image',
      backgroundValue: json['backgroundValue']?.toString() ?? 'default',
      albumImageUrls: (json['albumImageUrls'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      publishedAlbumUrl: json['publishedAlbumUrl']?.toString(),
      publishedAlbumAt: parseDateOrMillis(json['publishedAlbumAt']),
      publishedAlbumDurationSeconds:
          (json['publishedAlbumDurationSeconds'] as num?)?.toInt(),
      publishedAlbumFit: json['publishedAlbumFit']?.toString() ?? 'cover',
      publishedAlbumExpiresAt: parseDateOrMillis(json['publishedAlbumExpiresAt']),
      publishedAlbumActive: json['publishedAlbumActive'] == true,
      primaryColor: json['primaryColor']?.toString() ?? '#1B5E3B',
      secondaryColor: json['secondaryColor']?.toString() ?? '#E8F5E9',
      activeCardColor: json['activeCardColor']?.toString() ?? '#C8E6C9',
      activeCardTextColor: json['activeCardTextColor']?.toString() ?? '#1B5E3B',
      inactiveCardColor: json['inactiveCardColor']?.toString() ?? '#EFEBE9',
      prayerOverlayColor: json['prayerOverlayColor']?.toString() ?? '#E8F5E9',
      inactiveCardTextColor:
          json['inactiveCardTextColor']?.toString() ?? '#2E7D32',
      countdownTextColor: json['countdownTextColor']?.toString() ?? '#FFFFFF',
      countdownBackgroundColor:
          json['countdownBackgroundColor']?.toString() ?? '#143B4E',
      alertTextColor: json['alertTextColor']?.toString() ?? '#FFFFFF',
      alertBackgroundColor:
          json['alertBackgroundColor']?.toString() ?? '#B3261E',
      clockFontSize: readDouble('clockFontSize', 20.0),
      mosqueInfoFontSize: readDouble('mosqueInfoFontSize', 20.0),
      prayersFontSize: readDouble('prayersFontSize', 20.0),
      announcementsFontSize: readDouble('announcementsFontSize', 20.0),
      contentFontSize: readDouble('contentFontSize', 20.0),
      tickerSpeed: readDouble('tickerSpeed', 1.0),
      stripSpeed: readDouble('stripSpeed', 1.0),
      prayerCardScale: readDouble('prayerCardScale', 1.0),
      religiousContentWaitSeconds:
          readInt('religiousContentWaitSeconds', 30),
      religiousContentDisplaySeconds:
          readInt('religiousContentDisplaySeconds', 15),
      numeralFormat:
          AppNumeralFormat.fromCode(json['numeralFormat']?.toString() ?? 'en'),
      fontFamily: json['fontFamily']?.toString() ?? 'Beiruti',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mosqueId': mosqueId,
      'backgroundType': backgroundType,
      'backgroundValue': backgroundValue,
      'albumImageUrls': albumImageUrls,
      'publishedAlbumUrl': publishedAlbumUrl,
      'publishedAlbumAt': publishedAlbumAt?.toIso8601String(),
      'publishedAlbumDurationSeconds': publishedAlbumDurationSeconds,
      'publishedAlbumFit': publishedAlbumFit,
      'publishedAlbumExpiresAt': publishedAlbumExpiresAt?.toIso8601String(),
      'publishedAlbumActive': publishedAlbumActive,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'activeCardColor': activeCardColor,
      'activeCardTextColor': activeCardTextColor,
      'inactiveCardColor': inactiveCardColor,
      'prayerOverlayColor': prayerOverlayColor,
      'inactiveCardTextColor': inactiveCardTextColor,
      'countdownTextColor': countdownTextColor,
      'countdownBackgroundColor': countdownBackgroundColor,
      'alertTextColor': alertTextColor,
      'alertBackgroundColor': alertBackgroundColor,
      'clockFontSize': clockFontSize,
      'mosqueInfoFontSize': mosqueInfoFontSize,
      'prayersFontSize': prayersFontSize,
      'announcementsFontSize': announcementsFontSize,
      'contentFontSize': contentFontSize,
      'tickerSpeed': tickerSpeed,
      'stripSpeed': stripSpeed,
      'prayerCardScale': prayerCardScale,
      'religiousContentWaitSeconds': religiousContentWaitSeconds,
      'religiousContentDisplaySeconds': religiousContentDisplaySeconds,
      'numeralFormat': numeralFormat.code,
      'fontFamily': fontFamily,
    };
  }

  /// Backend write body for `PUT .../display-settings` (full replacement, no
  /// server-owned fields).
  Map<String, dynamic> toRequestBody() {
    final body = toJson();
    body.remove('mosqueId');
    body.remove('publishedAlbumExpiresAt');
    body.remove('publishedAlbumActive');
    return body;
  }

  DisplaySettings copyWith({
    String? mosqueId,
    String? backgroundType,
    String? backgroundValue,
    List<String>? albumImageUrls,
    String? publishedAlbumUrl,
    DateTime? publishedAlbumAt,
    int? publishedAlbumDurationSeconds,
    String? publishedAlbumFit,
    DateTime? publishedAlbumExpiresAt,
    bool? publishedAlbumActive,
    String? primaryColor,
    String? secondaryColor,
    String? activeCardColor,
    String? activeCardTextColor,
    String? inactiveCardColor,
    String? prayerOverlayColor,
    String? inactiveCardTextColor,
    String? countdownTextColor,
    String? countdownBackgroundColor,
    String? alertTextColor,
    String? alertBackgroundColor,
    double? clockFontSize,
    double? mosqueInfoFontSize,
    double? prayersFontSize,
    double? announcementsFontSize,
    double? contentFontSize,
    double? tickerSpeed,
    double? stripSpeed,
    double? prayerCardScale,
    int? religiousContentWaitSeconds,
    int? religiousContentDisplaySeconds,
    AppNumeralFormat? numeralFormat,
    String? fontFamily,
  }) {
    return DisplaySettings(
      mosqueId: mosqueId ?? this.mosqueId,
      backgroundType: backgroundType ?? this.backgroundType,
      backgroundValue: backgroundValue ?? this.backgroundValue,
      albumImageUrls: albumImageUrls ?? this.albumImageUrls,
      publishedAlbumUrl: publishedAlbumUrl ?? this.publishedAlbumUrl,
      publishedAlbumAt: publishedAlbumAt ?? this.publishedAlbumAt,
      publishedAlbumDurationSeconds:
          publishedAlbumDurationSeconds ?? this.publishedAlbumDurationSeconds,
      publishedAlbumFit: publishedAlbumFit ?? this.publishedAlbumFit,
      publishedAlbumExpiresAt:
          publishedAlbumExpiresAt ?? this.publishedAlbumExpiresAt,
      publishedAlbumActive: publishedAlbumActive ?? this.publishedAlbumActive,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      activeCardColor: activeCardColor ?? this.activeCardColor,
      activeCardTextColor: activeCardTextColor ?? this.activeCardTextColor,
      inactiveCardColor: inactiveCardColor ?? this.inactiveCardColor,
      prayerOverlayColor: prayerOverlayColor ?? this.prayerOverlayColor,
      inactiveCardTextColor:
          inactiveCardTextColor ?? this.inactiveCardTextColor,
      countdownTextColor: countdownTextColor ?? this.countdownTextColor,
      countdownBackgroundColor:
          countdownBackgroundColor ?? this.countdownBackgroundColor,
      alertTextColor: alertTextColor ?? this.alertTextColor,
      alertBackgroundColor: alertBackgroundColor ?? this.alertBackgroundColor,
      clockFontSize: clockFontSize ?? this.clockFontSize,
      mosqueInfoFontSize: mosqueInfoFontSize ?? this.mosqueInfoFontSize,
      prayersFontSize: prayersFontSize ?? this.prayersFontSize,
      announcementsFontSize:
          announcementsFontSize ?? this.announcementsFontSize,
      contentFontSize: contentFontSize ?? this.contentFontSize,
      tickerSpeed: tickerSpeed ?? this.tickerSpeed,
      stripSpeed: stripSpeed ?? this.stripSpeed,
      prayerCardScale: prayerCardScale ?? this.prayerCardScale,
      religiousContentWaitSeconds:
          religiousContentWaitSeconds ?? this.religiousContentWaitSeconds,
      religiousContentDisplaySeconds:
          religiousContentDisplaySeconds ?? this.religiousContentDisplaySeconds,
      numeralFormat: numeralFormat ?? this.numeralFormat,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  @override
  List<Object?> get props => [
        mosqueId,
        backgroundType,
        backgroundValue,
        albumImageUrls,
        publishedAlbumUrl,
        publishedAlbumAt,
        publishedAlbumDurationSeconds,
        publishedAlbumFit,
        publishedAlbumExpiresAt,
        publishedAlbumActive,
        primaryColor,
        secondaryColor,
        activeCardColor,
        activeCardTextColor,
        inactiveCardColor,
        prayerOverlayColor,
        inactiveCardTextColor,
        countdownTextColor,
        countdownBackgroundColor,
        alertTextColor,
        alertBackgroundColor,
        clockFontSize,
        mosqueInfoFontSize,
        prayersFontSize,
        announcementsFontSize,
        contentFontSize,
        tickerSpeed,
        stripSpeed,
        prayerCardScale,
        religiousContentWaitSeconds,
        religiousContentDisplaySeconds,
        numeralFormat,
        fontFamily,
      ];
}
