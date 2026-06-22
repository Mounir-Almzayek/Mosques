import '../../datasources/notifications_remote_data_source.dart';

abstract class INotificationsRepository {
  Future<NotificationInboxPage> list({int limit, String? cursor});
  Future<int> unreadCount();
  Future<int> markRead(String messageId);
  Stream<Map<String, dynamic>> watchEvents();
}
