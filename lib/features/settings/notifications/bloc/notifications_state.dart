import 'package:equatable/equatable.dart';

import '../../../../data/models/notification_inbox_item.dart';

class NotificationsState extends Equatable {
  final List<NotificationInboxItem> items;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  const NotificationsState({
    this.items = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<NotificationInboxItem>? items,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [items, unreadCount, isLoading, error];
}
