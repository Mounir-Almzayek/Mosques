import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'recitation_ai_models.dart';

class RecitationAudioStreamer {
  final AudioRecorder _recorder = AudioRecorder();
  WebSocketChannel? _channel;
  StreamSubscription<Uint8List>? _audioSub;
  StreamSubscription<dynamic>? _socketSub;
  int _seq = 0;

  Future<void> start({
    required RecitationSessionAuthorization authorization,
    required PositionHint positionHint,
    required void Function(Map<String, dynamic> event) onEvent,
    required void Function(Object error) onError,
  }) async {
    if (!await _recorder.hasPermission()) {
      throw StateError('microphone_permission_denied');
    }

    _channel = WebSocketChannel.connect(Uri.parse(authorization.websocketUrl));
    _socketSub = _channel!.stream.listen(
      (raw) {
        final event = _decode(raw);
        if (event != null) onEvent(event);
      },
      onError: onError,
      cancelOnError: false,
    );

    _send({'type': 'session_start'});
    _send(positionHint.toWireJson());

    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
        echoCancel: false,
        noiseSuppress: false,
      ),
    );
    _audioSub = stream.listen(
      _sendAudio,
      onError: onError,
      cancelOnError: false,
    );
  }

  Future<void> stop() async {
    _send({'type': 'session_end'});
    await _audioSub?.cancel();
    _audioSub = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    await _socketSub?.cancel();
    _socketSub = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  Future<void> dispose() => stop();

  void _sendAudio(Uint8List bytes) {
    _send({
      'type': 'audio',
      'seq': ++_seq,
      'ts_ms': DateTime.now().millisecondsSinceEpoch,
      'format': 'pcm16/16k/mono',
      'pcm_b64': base64Encode(bytes),
    });
  }

  void _send(Map<String, dynamic> payload) {
    _channel?.sink.add(jsonEncode(payload));
  }

  Map<String, dynamic>? _decode(dynamic raw) {
    try {
      final text = raw is List<int> ? utf8.decode(raw) : raw.toString();
      final decoded = jsonDecode(text);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }
}
