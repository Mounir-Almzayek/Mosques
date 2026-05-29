import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/media/media_widgets.dart';

class AlbumPublishBottomSheet extends StatefulWidget {
  final String url;
  final bool isLive;
  final void Function(int durationSeconds) onPublish;
  final VoidCallback onUnpublish;
  final VoidCallback onDelete;

  const AlbumPublishBottomSheet({
    super.key,
    required this.url,
    required this.isLive,
    required this.onPublish,
    required this.onUnpublish,
    required this.onDelete,
  });

  @override
  State<AlbumPublishBottomSheet> createState() =>
      _AlbumPublishBottomSheetState();
}

class _AlbumPublishBottomSheetState extends State<AlbumPublishBottomSheet> {
  int _durationSeconds = 60;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        left: 24,
        right: 24,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 160,
              child: AppImage.network(widget.url, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                s.album_publish_duration,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '$_durationSeconds ${s.album_seconds_suffix}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Slider(
            value: _durationSeconds.toDouble(),
            min: 10,
            max: 300,
            divisions: 29,
            activeColor: const Color(0xFF1A3C34),
            onChanged: (value) {
              setState(() => _durationSeconds = value.toInt());
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10 ${s.album_seconds_suffix}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              Text(
                '300 ${s.album_seconds_suffix}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => widget.onPublish(_durationSeconds),
            icon: const Icon(Icons.play_circle_outline),
            label: Text(s.album_publish),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A3C34),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          if (widget.isLive) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: widget.onUnpublish,
              icon: const Icon(Icons.stop_circle_outlined),
              label: Text(s.album_unpublish),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade700,
                side: BorderSide(color: Colors.orange.shade700),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: widget.onDelete,
            icon: const Icon(Icons.delete_outline),
            label: Text(s.delete),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
