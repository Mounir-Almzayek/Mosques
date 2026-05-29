import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/utils/box_fit_codec.dart';
import '../../../../core/widgets/media/media_widgets.dart';
import '../../core/widgets/duration_counter_field.dart';

class AlbumPublishBottomSheet extends StatefulWidget {
  final String url;
  final bool isLive;

  /// Initial duration and fit, so re-opening a live image shows its settings.
  final int initialDurationSeconds;
  final String initialFit;
  final void Function(int durationSeconds, String fit) onPublish;
  final VoidCallback onUnpublish;
  final VoidCallback onDelete;

  const AlbumPublishBottomSheet({
    super.key,
    required this.url,
    required this.isLive,
    this.initialDurationSeconds = 60,
    this.initialFit = 'contain',
    required this.onPublish,
    required this.onUnpublish,
    required this.onDelete,
  });

  @override
  State<AlbumPublishBottomSheet> createState() =>
      _AlbumPublishBottomSheetState();
}

class _AlbumPublishBottomSheetState extends State<AlbumPublishBottomSheet> {
  late int _durationSeconds = widget.initialDurationSeconds;
  late String _fit = widget.initialFit;

  String _fitLabel(String name, S s) {
    switch (name) {
      case 'cover':
        return s.album_fit_cover;
      case 'fill':
        return s.album_fit_fill;
      case 'fitWidth':
        return s.album_fit_fit_width;
      case 'fitHeight':
        return s.album_fit_fit_height;
      case 'contain':
      default:
        return s.album_fit_contain;
    }
  }

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
      child: SingleChildScrollView(
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
              child: Container(
                height: 180,
                color: Colors.black12,
                child: AppImage.network(
                  widget.url,
                  fit: boxFitFromName(_fit),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                s.album_fit_label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final name in kAlbumFitNames)
                  ChoiceChip(
                    label: Text(_fitLabel(name, s)),
                    selected: _fit == name,
                    onSelected: (_) => setState(() => _fit = name),
                    selectedColor: const Color(0xFF1A3C34),
                    labelStyle: TextStyle(
                      color: _fit == name ? Colors.white : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            DurationCounterField(
              label: s.album_publish_duration,
              value: _durationSeconds,
              step: 10,
              min: 10,
              suffix: s.album_seconds_suffix,
              onChanged: (v) => setState(() => _durationSeconds = v),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => widget.onPublish(_durationSeconds, _fit),
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
      ),
    );
  }
}
