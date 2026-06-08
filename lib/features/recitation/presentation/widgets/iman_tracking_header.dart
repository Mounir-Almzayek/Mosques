import 'package:flutter/material.dart';

class ImamTrackingHeader extends StatelessWidget {
  final bool isRecording;
  final int currentPage;
  final int totalPages;
  final DateTime? lastRecordedAt;

  const ImamTrackingHeader({
    super.key,
    required this.isRecording,
    required this.currentPage,
    required this.totalPages,
    required this.lastRecordedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تتبع قراءة الإمام',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _InfoBadge(
              label: isRecording ? 'التتبع نشط' : 'جاهز للتتبع',
              color: isRecording ? Colors.green.shade700 : Colors.blueGrey,
            ),
            _InfoBadge(
              label: 'الصفحة $currentPage من $totalPages',
              color: Colors.grey.shade700,
            ),
          ],
        ),
        if (lastRecordedAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'آخر تتبع: ${_formatTimestamp(lastRecordedAt!)}',
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
