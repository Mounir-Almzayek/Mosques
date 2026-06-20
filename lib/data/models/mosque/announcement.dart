import 'package:equatable/equatable.dart';

import '../../../core/utils/date_parse.dart';

/// Announcement / alert — 1:1 with backend `AnnouncementResponse`.
///
/// Field names match the backend verbatim (`startAt`/`endAt`/`displayOrder`),
/// dropping the Firebase-era aliases (`startDate`/`order`/`isPublished`).
class Announcement extends Equatable {
  final String id;
  final String scope;
  final String audience;
  final String announcementType;
  final String? mosqueId;
  final String title;
  final String? subtitle;
  final DateTime startAt;
  final DateTime endAt;
  final String? qrCodeUrl;
  final bool isActive;
  final bool isPriority;
  final int displayDurationSeconds;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Announcement({
    this.id = '',
    this.scope = 'mosque',
    this.audience = 'display',
    this.announcementType = 'announcement',
    this.mosqueId,
    this.title = '',
    this.subtitle,
    required this.startAt,
    required this.endAt,
    this.qrCodeUrl,
    this.isActive = true,
    this.isPriority = false,
    this.displayDurationSeconds = 30,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAlert => announcementType == 'alert';

  bool isActiveAt(DateTime now) {
    if (!isActive) return false;
    if (now.isBefore(startAt)) return false;
    if (!now.isBefore(endAt)) return false;
    return true;
  }

  factory Announcement.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return Announcement(
      id: json['id']?.toString() ?? '',
      scope: json['scope']?.toString() ?? 'mosque',
      audience: json['audience']?.toString() ?? 'display',
      announcementType: json['announcementType']?.toString() ?? 'announcement',
      mosqueId: json['mosqueId']?.toString(),
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      startAt: parseDateOrMillis(json['startAt']) ?? now,
      endAt: parseDateOrMillis(json['endAt']) ??
          now.add(const Duration(hours: 1)),
      qrCodeUrl: json['qrCodeUrl']?.toString(),
      isActive: json['isActive'] != false,
      isPriority: json['isPriority'] == true,
      displayDurationSeconds:
          (json['displayDurationSeconds'] as num?)?.toInt() ?? 30,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      createdAt: parseDateOrMillis(json['createdAt']),
      updatedAt: parseDateOrMillis(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'scope': scope,
        'audience': audience,
        'announcementType': announcementType,
        if (mosqueId != null) 'mosqueId': mosqueId,
        'title': title,
        'subtitle': subtitle,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
        'qrCodeUrl': qrCodeUrl,
        'isActive': isActive,
        'isPriority': isPriority,
        'displayDurationSeconds': displayDurationSeconds,
        'displayOrder': displayOrder,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  /// Backend create/update body (`AnnouncementRequest`): no server-owned
  /// fields, `audience`/`announcementType` required.
  Map<String, dynamic> toRequestBody() => {
        'announcementType': announcementType,
        'audience': audience,
        'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        'startAt': startAt.toUtc().toIso8601String(),
        'endAt': endAt.toUtc().toIso8601String(),
        if (qrCodeUrl != null) 'qrCodeUrl': qrCodeUrl,
        'isActive': isActive,
        'isPriority': isPriority,
        'displayDurationSeconds': displayDurationSeconds,
        'displayOrder': displayOrder,
      };

  Announcement copyWith({
    String? id,
    String? scope,
    String? audience,
    String? announcementType,
    String? mosqueId,
    String? title,
    String? subtitle,
    DateTime? startAt,
    DateTime? endAt,
    String? qrCodeUrl,
    bool? isActive,
    bool? isPriority,
    int? displayDurationSeconds,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Announcement(
      id: id ?? this.id,
      scope: scope ?? this.scope,
      audience: audience ?? this.audience,
      announcementType: announcementType ?? this.announcementType,
      mosqueId: mosqueId ?? this.mosqueId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      isActive: isActive ?? this.isActive,
      isPriority: isPriority ?? this.isPriority,
      displayDurationSeconds:
          displayDurationSeconds ?? this.displayDurationSeconds,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        scope,
        audience,
        announcementType,
        mosqueId,
        title,
        subtitle,
        startAt,
        endAt,
        qrCodeUrl,
        isActive,
        isPriority,
        displayDurationSeconds,
        displayOrder,
        createdAt,
        updatedAt,
      ];
}
