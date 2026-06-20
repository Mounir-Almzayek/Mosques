import 'package:equatable/equatable.dart';

import '../../../core/utils/date_parse.dart';

class SettingsAnnouncementModel extends Equatable {
  const SettingsAnnouncementModel({
    required this.id,
    required this.title,
    this.body,
    this.imageUrl,
    this.linkUrl,
    this.isActive = true,
    this.order = 0,
    this.startDate,
    this.endDate,
  });

  final String id;
  final String title;
  final String? body;
  final String? imageUrl;
  final String? linkUrl;
  final bool isActive;
  final int order;
  final DateTime? startDate;
  final DateTime? endDate;

  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;
  bool get hasBody => body != null && body!.trim().isNotEmpty;
  bool get hasLink => linkUrl != null && linkUrl!.trim().isNotEmpty;

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
    final title = (map['title'] ?? '').toString();
    final body = map['subtitle']?.toString().trim();
    final imageUrl = map['imageUrl']?.toString().trim();
    final linkUrl = map['qrCodeUrl']?.toString().trim();

    return SettingsAnnouncementModel(
      id: id,
      title: title.trim(),
      body: body == null || body.isEmpty ? null : body,
      imageUrl: imageUrl == null || imageUrl.isEmpty
          ? null
          : imageUrl,
      linkUrl: linkUrl == null || linkUrl.isEmpty ? null : linkUrl,
      isActive: map['isActive'] as bool? ?? true,
      order: (map['displayOrder'] as num?)?.toInt() ?? 0,
      startDate: parseDateOrMillis(map['startAt']),
      endDate: parseDateOrMillis(map['endAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': body,
      'imageUrl': imageUrl,
      'qrCodeUrl': linkUrl,
      'isActive': isActive,
      'displayOrder': order,
      'startAt': startDate?.toIso8601String(),
      'endAt': endDate?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    imageUrl,
    linkUrl,
    isActive,
    order,
    startDate,
    endDate,
  ];
}
