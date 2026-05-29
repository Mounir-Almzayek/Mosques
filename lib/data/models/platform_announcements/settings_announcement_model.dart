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
    final title = (map['title'] ?? map['headline'] ?? '').toString();
    final body = (map['body'] ?? map['subtitle'] ?? map['message'])
        ?.toString()
        .trim();

    final imageUrl = (map['image_url'] ?? map['imageUrl'] ?? map['image'])
        ?.toString()
        .trim();
    var linkUrl =
        (map['link_url'] ??
                map['linkUrl'] ??
                map['link'] ??
                map['href'] ??
                map['cta_url'] ??
                map['ctaUrl'] ??
                map['target_url'] ??
                map['targetUrl'])
            ?.toString()
            .trim();

    // Backwards-compat: some payloads may contain `url`.
    // If an explicit image field exists, treat `url` as a link.
    // Otherwise keep old behavior (treat `url` as image).
    final rawUrl = map['url']?.toString().trim();
    final resolvedImageUrl =
        imageUrl ?? (rawUrl?.isNotEmpty == true ? rawUrl : null);
    if ((linkUrl == null || linkUrl.isEmpty) &&
        (imageUrl != null && imageUrl.isNotEmpty) &&
        rawUrl != null &&
        rawUrl.isNotEmpty) {
      linkUrl = rawUrl;
    }

    return SettingsAnnouncementModel(
      id: id,
      title: title.trim(),
      body: body == null || body.isEmpty ? null : body,
      imageUrl: resolvedImageUrl == null || resolvedImageUrl.isEmpty
          ? null
          : resolvedImageUrl,
      linkUrl: linkUrl == null || linkUrl.isEmpty ? null : linkUrl,
      isActive: map['is_active'] as bool? ?? map['active'] as bool? ?? true,
      order: (map['order'] as num?)?.toInt() ?? 0,
      startDate: parseDateOrMillis(map['start_date'] ?? map['startDate']),
      endDate: parseDateOrMillis(map['end_date'] ?? map['endDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'image_url': imageUrl,
      'link_url': linkUrl,
      'is_active': isActive,
      'order': order,
      'start_date': startDate,
      'end_date': endDate,
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
