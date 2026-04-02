import 'package:equatable/equatable.dart';

/// Grouped font size settings for all UI components on the display.
class FontSizeSettings extends Equatable {
  final double clock;
  final double mosqueInfo;
  final double prayers;
  final double announcements;
  final double content;

  const FontSizeSettings({
    this.clock = 20.0,
    this.mosqueInfo = 20.0,
    this.prayers = 20.0,
    this.announcements = 20.0,
    this.content = 20.0,
  });

  factory FontSizeSettings.fromMap(Map<String, dynamic> map) {
    // Falls back to a shared 'base_font_size' if individual keys are missing (migration).
    final base = (map['base_font_size'] ?? 20.0).toDouble();
    return FontSizeSettings(
      clock: (map['clock_font_size'] ?? base).toDouble(),
      mosqueInfo: (map['mosque_info_font_size'] ?? base).toDouble(),
      prayers: (map['prayers_font_size'] ?? base).toDouble(),
      announcements: (map['announcements_font_size'] ?? base).toDouble(),
      content: (map['content_font_size'] ?? base).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clock_font_size': clock,
      'mosque_info_font_size': mosqueInfo,
      'prayers_font_size': prayers,
      'announcements_font_size': announcements,
      'content_font_size': content,
    };
  }

  FontSizeSettings copyWith({
    double? clock,
    double? mosqueInfo,
    double? prayers,
    double? announcements,
    double? content,
  }) {
    return FontSizeSettings(
      clock: clock ?? this.clock,
      mosqueInfo: mosqueInfo ?? this.mosqueInfo,
      prayers: prayers ?? this.prayers,
      announcements: announcements ?? this.announcements,
      content: content ?? this.content,
    );
  }

  @override
  List<Object?> get props => [clock, mosqueInfo, prayers, announcements, content];
}
