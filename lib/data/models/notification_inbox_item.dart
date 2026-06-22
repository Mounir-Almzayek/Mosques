import 'package:equatable/equatable.dart';

import '../../core/utils/date_parse.dart';

class NotificationInboxItem extends Equatable {
  final String id;
  final String messageId;
  final String? mosqueId;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String targetScope;
  final DateTime? readAt;
  final DateTime? createdAt;

  const NotificationInboxItem({
    required this.id,
    required this.messageId,
    this.mosqueId,
    required this.title,
    required this.body,
    this.data = const {},
    required this.targetScope,
    this.readAt,
    this.createdAt,
  });

  bool get isRead => readAt != null;

  factory NotificationInboxItem.fromJson(Map<String, dynamic> json) {
    return NotificationInboxItem(
      id: json['id']?.toString() ?? '',
      messageId: json['messageId']?.toString() ?? '',
      mosqueId: json['mosqueId']?.toString(),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      data: (json['data'] as Map?)?.cast<String, dynamic>() ?? const {},
      targetScope: json['targetScope']?.toString() ?? 'mosque_members',
      readAt: parseDateOrMillis(json['readAt']),
      createdAt: parseDateOrMillis(json['createdAt']),
    );
  }

  NotificationInboxItem copyWith({DateTime? readAt}) {
    return NotificationInboxItem(
      id: id,
      messageId: messageId,
      mosqueId: mosqueId,
      title: title,
      body: body,
      data: data,
      targetScope: targetScope,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    messageId,
    mosqueId,
    title,
    body,
    data,
    targetScope,
    readAt,
    createdAt,
  ];
}
