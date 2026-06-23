import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/config/api_config.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/services/api_service.dart';
import '../../core/services/token_storage.dart';
import '../models/notification_inbox_item.dart';

class NotificationInboxPage {
  final List<NotificationInboxItem> items;
  final String? nextCursor;
  final bool hasMore;
  final int unreadCount;

  const NotificationInboxPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
    this.unreadCount = 0,
  });
}

class NotificationsRemoteDataSource {
  final ApiService _api;
  final TokenStorage _tokens;

  NotificationsRemoteDataSource({
    required ApiService api,
    required TokenStorage tokens,
  }) : _api = api,
       _tokens = tokens;

  Future<NotificationInboxPage> list({
    int limit = 30,
    String? cursor,
    bool unreadOnly = false,
  }) async {
    final data = await _api.get(
      ApiEndpoints.notifications,
      query: {
        'limit': limit,
        'cursor': ?cursor,
        if (unreadOnly) 'unreadOnly': true,
      },
    );
    final raw = data['items'];
    final meta = data['meta'];
    return NotificationInboxPage(
      items: raw is List
          ? raw
                .whereType<Map>()
                .map(
                  (item) => NotificationInboxItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
      nextCursor: meta is Map ? meta['nextCursor']?.toString() : null,
      hasMore: meta is Map && meta['hasMore'] == true,
      unreadCount: (data['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  Future<int> unreadCount() async {
    final data = await _api.get(ApiEndpoints.notificationsUnreadCount);
    return (data['unreadCount'] as num?)?.toInt() ?? 0;
  }

  Future<int> markRead(String messageId) async {
    final data = await _api.patch(ApiEndpoints.notificationRead(messageId));
    return (data['unreadCount'] as num?)?.toInt() ?? 0;
  }

  Stream<Map<String, dynamic>> watchEvents() {
    final controller = StreamController<Map<String, dynamic>>();
    WebSocketChannel? channel;
    Timer? reconnectTimer;

    void connect() {
      if (controller.isClosed) return;
      final currentChannel = channel;
      if (currentChannel != null) {
        unawaited(currentChannel.sink.close());
      }
      final token = _tokens.accessToken;
      final uri =
          Uri.parse(
            '${ApiConfig.wsBaseUrl}${ApiEndpoints.notificationsWs}',
          ).replace(
            queryParameters: {
              if (token != null && token.isNotEmpty) 'access_token': token,
            },
          );
      try {
        channel = WebSocketChannel.connect(uri);
      } catch (_) {
        reconnectTimer?.cancel();
        reconnectTimer = Timer(const Duration(seconds: 2), connect);
        return;
      }
      channel!.ready.catchError((_) {
        if (!controller.isClosed) {
          reconnectTimer?.cancel();
          reconnectTimer = Timer(const Duration(seconds: 2), connect);
        }
      });
      channel!.stream.listen(
        (raw) {
          try {
            final decoded = jsonDecode(raw.toString());
            if (decoded is Map) {
              controller.add(Map<String, dynamic>.from(decoded));
            }
          } catch (_) {}
        },
        onError: (_) {
          if (!controller.isClosed) {
            reconnectTimer?.cancel();
            reconnectTimer = Timer(const Duration(seconds: 2), connect);
          }
        },
        onDone: () {
          if (!controller.isClosed) {
            reconnectTimer?.cancel();
            reconnectTimer = Timer(const Duration(seconds: 2), connect);
          }
        },
      );
    }

    controller.onListen = connect;
    controller.onCancel = () async {
      reconnectTimer?.cancel();
      await channel?.sink.close();
    };
    return controller.stream;
  }
}
