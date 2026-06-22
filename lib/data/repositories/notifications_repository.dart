import '../datasources/notifications_remote_data_source.dart';
import 'interfaces/notifications_repository_interface.dart';

class NotificationsRepository implements INotificationsRepository {
  final NotificationsRemoteDataSource _dataSource;

  NotificationsRepository({required NotificationsRemoteDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<NotificationInboxPage> list({int limit = 30, String? cursor}) {
    return _dataSource.list(limit: limit, cursor: cursor);
  }

  @override
  Future<int> markRead(String messageId) => _dataSource.markRead(messageId);

  @override
  Future<int> unreadCount() => _dataSource.unreadCount();

  @override
  Stream<Map<String, dynamic>> watchEvents() => _dataSource.watchEvents();
}
