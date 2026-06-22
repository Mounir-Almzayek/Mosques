import 'package:equatable/equatable.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsEvent {
  const LoadNotifications();
}

class RefreshNotifications extends NotificationsEvent {
  const RefreshNotifications();
}

class NotificationsRealtimeChanged extends NotificationsEvent {
  final int? unreadCount;

  const NotificationsRealtimeChanged({this.unreadCount});

  @override
  List<Object?> get props => [unreadCount];
}

class MarkNotificationReadRequested extends NotificationsEvent {
  final String messageId;

  const MarkNotificationReadRequested(this.messageId);

  @override
  List<Object?> get props => [messageId];
}
