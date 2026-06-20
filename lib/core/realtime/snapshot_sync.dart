import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/api_config.dart';
import '../constants/api_endpoints.dart';
import '../services/sync_revision_store.dart';
import '../services/token_storage.dart';

/// One live display-snapshot stream per mosque slug.
///
/// Opens a WebSocket to `/api/v1/display/mosques/{publicSlug}/ws`, sends a
/// `hello` frame with the cached `lastSyncRevision`, and emits every full
/// snapshot returned by the server. Heartbeat frames refresh a watchdog timer
/// so a silent network drop triggers a reconnect with exponential back-off.
class SnapshotSync {
  final TokenStorage _tokens;
  final Map<String, _MosqueChannel> _channels = {};
  final StreamController<Map<String, dynamic>> _recitationController =
      StreamController<Map<String, dynamic>>.broadcast();

  SnapshotSync({required TokenStorage tokens}) : _tokens = tokens;

  Stream<Map<String, dynamic>> get recitationEvents =>
      _recitationController.stream;

  /// Live stream of snapshots for [publicSlug]. Multiple listeners share one
  /// underlying WebSocket via a broadcast subject.
  Stream<Map<String, dynamic>> watch(String publicSlug) {
    final existing = _channels[publicSlug];
    if (existing != null) return existing.stream;
    final channel = _MosqueChannel(
      publicSlug: publicSlug,
      tokens: _tokens,
      onRecitationEvent: (event) {
        if (!_recitationController.isClosed) {
          _recitationController.add(event);
        }
      },
      onClosed: () => _channels.remove(publicSlug),
    );
    _channels[publicSlug] = channel;
    channel.connect();
    return channel.stream;
  }

  Future<void> close(String publicSlug) async {
    await _channels[publicSlug]?.dispose();
    _channels.remove(publicSlug);
  }

  Future<void> closeAll() async {
    final futures =
        _channels.values.map((c) => c.dispose()).toList(growable: false);
    _channels.clear();
    await Future.wait(futures);
  }
}

class _MosqueChannel {
  final String publicSlug;
  final TokenStorage tokens;
  final ValueChanged<Map<String, dynamic>> onRecitationEvent;
  final VoidCallback onClosed;
  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  Duration _reconnectDelay = ApiConfig.wsReconnectInitial;
  bool _disposed = false;

  _MosqueChannel({
    required this.publicSlug,
    required this.tokens,
    required this.onRecitationEvent,
    required this.onClosed,
  });

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void connect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    final url = '${ApiConfig.wsBaseUrl}${ApiEndpoints.displayWs(publicSlug)}';
    try {
      final uri = Uri.parse(url);
      final token = tokens.accessToken;
      // Browser WS clients cannot set headers, so the access token is also
      // accepted via query string by the backend.
      final qp = <String, String>{
        if (token != null && token.isNotEmpty) 'access_token': token,
      };
      final resolved = qp.isEmpty
          ? uri
          : uri.replace(queryParameters: {...uri.queryParameters, ...qp});
      _channel = WebSocketChannel.connect(resolved);
    } catch (e) {
      _scheduleReconnect();
      return;
    }

    _sub = _channel!.stream.listen(
      _onMessage,
      onDone: _onDone,
      onError: _onError,
      cancelOnError: true,
    );

    // Send the hello frame with last known revision.
    final lastRevision = SyncRevisionStore.read(publicSlug);
    _send({
      'type': 'hello',
      'lastSyncRevision': ?lastRevision,
    });

    _resetHeartbeat();
  }

  void _send(Map<String, dynamic> payload) {
    try {
      _channel?.sink.add(jsonEncode(payload));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SnapshotSync send failed: $e');
      }
    }
  }

  void _onMessage(dynamic raw) {
    _resetHeartbeat();
    final decoded = _decodeFrame(raw);
    if (decoded == null) return;

    final type = decoded['type']?.toString();
    switch (type) {
      case 'display.snapshot':
      case 'display.snapshot.updated':
        final revision = (decoded['syncRevision'] as num?)?.toInt();
        final snapshot =
            (decoded['snapshot'] as Map?)?.cast<String, dynamic>();
        if (snapshot == null) return;
        if (revision != null) {
          // Fire-and-forget: persist revision for the next reconnect.
          SyncRevisionStore.write(publicSlug, revision);
        }
        _controller.add(snapshot);
        break;
      case 'heartbeat':
        // Watchdog already reset above; nothing else to do.
        break;
      case 'display.recitation.updated':
        onRecitationEvent(decoded);
        break;
      default:
        if (kDebugMode) {
          debugPrint('SnapshotSync ignored frame: $type');
        }
    }
  }

  Map<String, dynamic>? _decodeFrame(dynamic raw) {
    try {
      if (raw is String) {
        final json = jsonDecode(raw);
        return json is Map ? Map<String, dynamic>.from(json) : null;
      }
      if (raw is List<int>) {
        final json = jsonDecode(utf8.decode(raw));
        return json is Map ? Map<String, dynamic>.from(json) : null;
      }
    } catch (_) {
      // Drop malformed frames silently.
    }
    return null;
  }

  void _resetHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer(ApiConfig.wsHeartbeatTimeout, () {
      if (kDebugMode) {
        debugPrint('SnapshotSync heartbeat timeout for $publicSlug');
      }
      _teardownAndReconnect();
    });
  }

  void _onDone() {
    if (_disposed) return;
    _teardownAndReconnect();
  }

  void _onError(Object error, [StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint('SnapshotSync error on $publicSlug: $error');
    }
    if (_disposed) return;
    _teardownAndReconnect();
  }

  void _teardownAndReconnect() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _sub?.cancel();
    _sub = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    final delay = _reconnectDelay;
    _reconnectDelay = Duration(
      seconds: (_reconnectDelay.inSeconds * 2)
          .clamp(1, ApiConfig.wsReconnectMax.inSeconds),
    );
    _reconnectTimer = Timer(delay, connect);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    await _sub?.cancel();
    try {
      await _channel?.sink.close();
    } catch (_) {}
    await _controller.close();
    onClosed();
  }
}
