import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class ImamAudioRecorder {
  final AudioRecorder _recorder = AudioRecorder();

  Future<void> start() async {
    if (!await _recorder.hasPermission()) {
      throw StateError('microphone_permission_denied');
    }

    final path = kIsWeb
        ? 'imam_tracking.wav'
        : '${(await getTemporaryDirectory()).path}/imam_tracking.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        numChannels: 1,
        echoCancel: true,
        noiseSuppress: true,
      ),
      path: path,
    );
  }

  Future<void> stop() async {
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
  }

  Future<void> dispose() async {
    await stop();
    _recorder.dispose();
  }
}
