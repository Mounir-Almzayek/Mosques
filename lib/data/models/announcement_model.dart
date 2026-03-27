import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../core/utils/firestore_date_parse.dart';

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
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map, String id) {
    final title = (map['title'] ?? '').toString();
    final subtitle = map['subtitle']?.toString();
    final startDate = parseFirestoreOrMillis(map['start_date']) ?? DateTime.now();
    final endDate = parseFirestoreOrMillis(map['end_date']) ?? DateTime.now().add(const Duration(hours: 1));
    final qrCodeUrl = map['qr_code_url']?.toString();
    final isActive = map['is_active'] ?? true;
    final order = map['order'] ?? 0;
    final isPriority = map['is_priority'] ?? false;
    final duration = map['display_duration_seconds'] ?? 30;

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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'qr_code_url': qrCodeUrl,
      'is_active': isActive,
      'order': order,
      'is_priority': isPriority,
      'display_duration_seconds': displayDurationSeconds,
    };
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
      ];
}
