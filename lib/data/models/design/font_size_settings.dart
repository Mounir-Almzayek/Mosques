import 'package:equatable/equatable.dart';

/// Grouped font size settings for all UI components on the display.
class FontSizeSettings extends Equatable {
  final double clock;
  final double mosqueInfo;
  final double prayers;
  final double announcements;
  final double religiousContent;
  final double alerts;
  final double countdown;

  const FontSizeSettings({
    this.clock = 20.0,
    this.mosqueInfo = 20.0,
    this.prayers = 20.0,
    this.announcements = 20.0,
    this.religiousContent = 20.0,
    this.alerts = 20.0,
    this.countdown = 20.0,
  });

  factory FontSizeSettings.fromMap(Map<String, dynamic> map) {
    final base = (map['base_font_size'] ?? 20.0).toDouble();
    return FontSizeSettings(
      clock: (map['clock_font_size'] ?? base).toDouble(),
      mosqueInfo: (map['mosque_info_font_size'] ?? base).toDouble(),
      prayers: (map['prayers_font_size'] ?? base).toDouble(),
      announcements: (map['announcements_font_size'] ?? base).toDouble(),
      religiousContent: (map['religious_content_font_size'] ?? map['content_font_size'] ?? base).toDouble(),
      alerts: (map['alerts_font_size'] ?? base).toDouble(),
      countdown: (map['countdown_font_size'] ?? base).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clock_font_size': clock,
      'mosque_info_font_size': mosqueInfo,
      'prayers_font_size': prayers,
      'announcements_font_size': announcements,
      'religious_content_font_size': religiousContent,
      'alerts_font_size': alerts,
      'countdown_font_size': countdown,
    };
  }

  FontSizeSettings copyWith({
    double? clock,
    double? mosqueInfo,
    double? prayers,
    double? announcements,
    double? religiousContent,
    double? alerts,
    double? countdown,
  }) {
    return FontSizeSettings(
      clock: clock ?? this.clock,
      mosqueInfo: mosqueInfo ?? this.mosqueInfo,
      prayers: prayers ?? this.prayers,
      announcements: announcements ?? this.announcements,
      religiousContent: religiousContent ?? this.religiousContent,
      alerts: alerts ?? this.alerts,
      countdown: countdown ?? this.countdown,
    );
  }

  @override
  List<Object?> get props => [clock, mosqueInfo, prayers, announcements, religiousContent, alerts, countdown];
}
