import 'package:flutter/material.dart';

class RecordingButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;

  const RecordingButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(isRecording ? Icons.stop_rounded : Icons.mic_rounded),
      label: Text(isRecording ? 'إيقاف التتبع' : 'بدء تتبع القراءة'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isRecording
            ? const Color(0xFF9F2D2D)
            : const Color(0xFF1F5C4A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
