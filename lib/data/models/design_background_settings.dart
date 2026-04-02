import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show Color;

import '../../core/enums/display_background_type.dart';
import '../../core/utils/color_parser.dart';

/// Comprehensive background configuration for the display screen.
/// Supports both image presets and solid colors in a single model.
class DesignBackgroundSettings extends Equatable {
  /// Whether we use an image or a solid color.
  final DisplayBackgroundType type;

  /// The unique identifier of the image (e.g. '01') or Hex string (e.g. '#FF0000').
  final String value;

  const DesignBackgroundSettings({
    this.type = DisplayBackgroundType.image,
    this.value = 'default',
  });

  factory DesignBackgroundSettings.fromMap(Map<String, dynamic> map) {
    return DesignBackgroundSettings(
      type: DisplayBackgroundType.fromCode(map['background_type']?.toString()),
      value: map['background_value']?.toString() ?? 'default',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'background_type': type.code,
      'background_value': value,
    };
  }

  DesignBackgroundSettings copyWith({
    DisplayBackgroundType? type,
    String? value,
  }) {
    return DesignBackgroundSettings(
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }

  /// Helper to get the color if type is color, or a fallback.
  Color resolveColor(Color fallback) {
    if (type == DisplayBackgroundType.color) {
       return parseColorHex(value, fallback);
    }
    return fallback;
  }

  @override
  List<Object?> get props => [type, value];
}
