import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../../core/utils/firestore_date_parse.dart';

class SettingsAnnouncementModel extends Equatable {
  const SettingsAnnouncementModel({
    required this.id,
    required this.title,
    this.body,
    this.imageUrl,
    this.isActive = true,
    this.order = 0,
    this.startDate,
    this.endDate,
  });

  final String id;
  final String title;
  final String? body;
  final String? imageUrl;
  final bool isActive;
  final int order;
  final DateTime? startDate;
  final DateTime? endDate;

  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;
  bool get hasBody => body != null && body!.trim().isNotEmpty;

  bool isVisibleAt(DateTime now) {
    if (!isActive) return false;
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && !now.isBefore(endDate!)) return false;
    return title.trim().isNotEmpty || hasBody || hasImage;
  }

  factory SettingsAnnouncementModel.fromMap(
    Map<String, dynamic> map,
    String fallbackId,
  ) {
    final id = (map['id'] ?? fallbackId).toString();
    final title = (map['title'] ?? map['headline'] ?? '').toString();
    final body = (map['body'] ?? map['subtitle'] ?? map['message'])
        ?.toString()
        .trim();
    final imageUrl = (map['image_url'] ?? map['imageUrl'] ?? map['url'])
        ?.toString()
        .trim();

    return SettingsAnnouncementModel(
      id: id,
      title: title.trim(),
      body: body == null || body.isEmpty ? null : body,
      imageUrl: imageUrl == null || imageUrl.isEmpty ? null : imageUrl,
      isActive: map['is_active'] as bool? ?? map['active'] as bool? ?? true,
      order: (map['order'] as num?)?.toInt() ?? 0,
      startDate: parseFirestoreOrMillis(map['start_date'] ?? map['startDate']),
      endDate: parseFirestoreOrMillis(map['end_date'] ?? map['endDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'image_url': imageUrl,
      'is_active': isActive,
      'order': order,
      'start_date': startDate == null ? null : Timestamp.fromDate(startDate!),
      'end_date': endDate == null ? null : Timestamp.fromDate(endDate!),
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    imageUrl,
    isActive,
    order,
    startDate,
    endDate,
  ];
}
