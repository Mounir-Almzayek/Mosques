import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show Color;
import '../../../core/utils/color_parser.dart';

class DesignColorSettings extends Equatable {
  final String primary;
  final String secondary;
  final String activeCard;
  final String activeCardText;
  final String prayerOverlay;
  final String inactiveCardText;
  final String countdownBackground;
  final String countdownText;
  final String alertBackground;
  final String alertText;

  const DesignColorSettings({
    this.primary = '#1B5E3B',
    this.secondary = '#E8F5E9',
    this.activeCard = '#C8E6C9',
    this.activeCardText = '#1B5E3B',
    this.prayerOverlay = '#E8F5E9',
    this.inactiveCardText = '#2E7D32',
    this.countdownBackground = '#C8E6C9',
    this.countdownText = '#1B5E3B',
    this.alertBackground = '#C8E6C9',
    this.alertText = '#1B5E3B',
  });

  factory DesignColorSettings.fromMap(Map<String, dynamic> map) {
    return DesignColorSettings(
      primary: map['primary_color']?.toString() ?? '#1B5E3B',
      secondary: map['secondary_color']?.toString() ?? '#E8F5E9',
      activeCard: map['active_card_color']?.toString() ?? '#C8E6C9',
      activeCardText: map['active_card_text_color']?.toString() ?? '#1B5E3B',
      prayerOverlay: map['prayer_overlay_color']?.toString() ?? '#E8F5E9',
      inactiveCardText:
          map['inactive_card_text_color']?.toString() ?? '#2E7D32',
      countdownBackground:
          map['countdown_background_color']?.toString() ?? '#C8E6C9',
      countdownText: map['countdown_text_color']?.toString() ?? '#1B5E3B',
      alertBackground: map['alert_background_color']?.toString() ?? '#C8E6C9',
      alertText: map['alert_text_color']?.toString() ?? '#1B5E3B',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primary_color': primary,
      'secondary_color': secondary,
      'active_card_color': activeCard,
      'active_card_text_color': activeCardText,
      'prayer_overlay_color': prayerOverlay,
      'inactive_card_text_color': inactiveCardText,
      'countdown_background_color': countdownBackground,
      'countdown_text_color': countdownText,
      'alert_background_color': alertBackground,
      'alert_text_color': alertText,
    };
  }

  DesignColorSettings copyWith({
    String? primary,
    String? secondary,
    String? activeCard,
    String? activeCardText,
    String? prayerOverlay,
    String? inactiveCardText,
    String? countdownBackground,
    String? countdownText,
    String? alertBackground,
    String? alertText,
  }) {
    return DesignColorSettings(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      activeCard: activeCard ?? this.activeCard,
      activeCardText: activeCardText ?? this.activeCardText,
      prayerOverlay: prayerOverlay ?? this.prayerOverlay,
      inactiveCardText: inactiveCardText ?? this.inactiveCardText,
      countdownBackground: countdownBackground ?? this.countdownBackground,
      countdownText: countdownText ?? this.countdownText,
      alertBackground: alertBackground ?? this.alertBackground,
      alertText: alertText ?? this.alertText,
    );
  }

  // Getters for parsed colors
  Color get primaryValue => parseColorHex(primary, const Color(0xFF1B5E3B));
  Color get secondaryValue => parseColorHex(secondary, const Color(0xFFE8F5E9));
  Color get activeCardValue =>
      parseColorHex(activeCard, const Color(0xFFC8E6C9));
  Color get activeCardTextValue =>
      parseColorHex(activeCardText, const Color(0xFF1B5E3B));
  Color get prayerOverlayValue =>
      parseColorHex(prayerOverlay, const Color(0xFFE8F5E9));
  Color get inactiveCardTextValue =>
      parseColorHex(inactiveCardText, const Color(0xFF2E7D32));
  Color get countdownBackgroundValue =>
      parseColorHex(countdownBackground, const Color(0xFFC8E6C9));
  Color get countdownTextValue =>
      parseColorHex(countdownText, const Color(0xFF1B5E3B));
  Color get alertBackgroundValue =>
      parseColorHex(alertBackground, const Color(0xFFC8E6C9));
  Color get alertTextValue =>
      parseColorHex(alertText, const Color(0xFF1B5E3B));

  @override
  List<Object?> get props => [
    primary,
    secondary,
    activeCard,
    activeCardText,
    prayerOverlay,
    inactiveCardText,
    countdownBackground,
    countdownText,
    alertBackground,
    alertText,
  ];
}
