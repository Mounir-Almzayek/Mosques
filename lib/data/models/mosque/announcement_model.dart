import 'package:equatable/equatable.dart';

import '../../../core/utils/date_parse.dart';

/// Represents a mosque announcement (Ad) or a high-priority instant alert.
class AnnouncementModel extends Equatable {
  final String id;
  final String title;
  final String? subtitle;
  final DateTime startDate;
  final DateTime endDate;
  final String? qrCodeUrl;
  final bool isActive;
  final int order;

  /// High-priority alerts appear full-screen and override regular content.
  final bool isPriority;

  /// Duration in seconds to show the alert once it enters the view.
  final int displayDurationSeconds;

  /// Whether this alert is currently published to the display.
  final bool isPublished;

  /// When this alert was last published.
  final DateTime? publishedAt;

  /// Duration in seconds for how long to show when published.
  final int publishDurationSeconds;

  const AnnouncementModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.startDate,
    required this.endDate,
    this.qrCodeUrl,
    this.isActive = true,
    this.order = 0,
    this.isPriority = false,
    this.displayDurationSeconds = 30,
    this.isPublished = false,
    this.publishedAt,
    this.publishDurationSeconds = 30,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map, String id) {
    final title = (map['title'] ?? '').toString();
    final subtitle = map['subtitle']?.toString();
    final startDate =
        parseDateOrMillis(map['start_date']) ?? DateTime.now();
    final endDate =
        parseDateOrMillis(map['end_date']) ??
        DateTime.now().add(const Duration(hours: 1));
    final qrCodeUrl = map['qr_code_url']?.toString();
    final isActive = map['is_active'] ?? true;
    final order = map['order'] ?? 0;
    final isPriority = map['is_priority'] ?? false;
    final duration = map['display_duration_seconds'] ?? 30;
    final isPublished = map['is_published'] ?? false;
    final publishedAt = parseDateOrMillis(map['published_at']);
    final publishDurationSeconds = map['publish_duration_seconds'] ?? 30;

    return AnnouncementModel(
      id: id,
      title: title,
      subtitle: subtitle,
      startDate: startDate,
      endDate: endDate,
      qrCodeUrl: qrCodeUrl,
      isActive: isActive,
      order: order,
      isPriority: isPriority,
      displayDurationSeconds: duration,
      isPublished: isPublished,
      publishedAt: publishedAt,
      publishDurationSeconds: publishDurationSeconds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'start_date': startDate,
      'end_date': endDate,
      'qr_code_url': qrCodeUrl,
      'is_active': isActive,
      'order': order,
      'is_priority': isPriority,
      'display_duration_seconds': displayDurationSeconds,
      'is_published': isPublished,
      'published_at': publishedAt,
      'publish_duration_seconds': publishDurationSeconds,
    };
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    DateTime? startDate,
    DateTime? endDate,
    String? qrCodeUrl,
    bool? isActive,
    int? order,
    bool? isPriority,
    int? displayDurationSeconds,
    bool? isPublished,
    DateTime? publishedAt,
    int? publishDurationSeconds,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      isPriority: isPriority ?? this.isPriority,
      displayDurationSeconds:
          displayDurationSeconds ?? this.displayDurationSeconds,
      isPublished: isPublished ?? this.isPublished,
      publishedAt: publishedAt ?? this.publishedAt,
      publishDurationSeconds:
          publishDurationSeconds ?? this.publishDurationSeconds,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    startDate,
    endDate,
    qrCodeUrl,
    isActive,
    order,
    isPriority,
    displayDurationSeconds,
    isPublished,
    publishedAt,
    publishDurationSeconds,
  ];
}
