import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show Color;
import '../../core/utils/color_parser.dart';

class DesignColorSettings extends Equatable {
  final String primary;
  final String secondary;
  final String activeCard;
  final String activeCardText;
  final String prayerOverlay;
  final String inactiveCardText;

  const DesignColorSettings({
    this.primary = '#143B4E',
    this.secondary = '#F3EEDC',
    this.activeCard = '#E5DCC3',
    this.activeCardText = '#143B4E',
    this.prayerOverlay = '#EFEBE9',
    this.inactiveCardText = '#5D4037',
  });

  factory DesignColorSettings.fromMap(Map<String, dynamic> map) {
    return DesignColorSettings(
      primary: map['primary_color']?.toString() ?? '#143B4E',
      secondary: map['secondary_color']?.toString() ?? '#F3EEDC',
      activeCard: map['active_card_color']?.toString() ?? '#E5DCC3',
      activeCardText: map['active_card_text_color']?.toString() ?? '#143B4E',
      prayerOverlay: map['prayer_overlay_color']?.toString() ?? '#EFEBE9',
      inactiveCardText: map['inactive_card_text_color']?.toString() ?? '#5D4037',
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
    };
  }

  DesignColorSettings copyWith({
    String? primary,
    String? secondary,
    String? activeCard,
    String? activeCardText,
    String? prayerOverlay,
    String? inactiveCardText,
  }) {
    return DesignColorSettings(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      activeCard: activeCard ?? this.activeCard,
      activeCardText: activeCardText ?? this.activeCardText,
      prayerOverlay: prayerOverlay ?? this.prayerOverlay,
      inactiveCardText: inactiveCardText ?? this.inactiveCardText,
    );
  }

  // Getters for parsed colors
  Color get primaryValue => parseColorHex(primary, const Color(0xFF143B4E));
  Color get secondaryValue => parseColorHex(secondary, const Color(0xFFF3EEDC));
  Color get activeCardValue => parseColorHex(activeCard, const Color(0xFFE5DCC3));
  Color get activeCardTextValue => parseColorHex(activeCardText, const Color(0xFF143B4E));
  Color get prayerOverlayValue => parseColorHex(prayerOverlay, const Color(0xFFEFEBE9));
  Color get inactiveCardTextValue => parseColorHex(inactiveCardText, const Color(0xFF5D4037));

  @override
  List<Object?> get props => [
        primary,
        secondary,
        activeCard,
        activeCardText,
        prayerOverlay,
        inactiveCardText,
      ];
}
