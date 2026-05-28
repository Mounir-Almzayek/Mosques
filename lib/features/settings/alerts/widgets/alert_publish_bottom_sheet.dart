import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/mosque/mosque_model.dart';

class AlertPublishBottomSheet extends StatefulWidget {
  final AnnouncementModel alert;
  final void Function(int durationSeconds) onPublish;

  const AlertPublishBottomSheet({
    super.key,
    required this.alert,
    required this.onPublish,
  });

  @override
  State<AlertPublishBottomSheet> createState() =>
      _AlertPublishBottomSheetState();
}

class _AlertPublishBottomSheetState extends State<AlertPublishBottomSheet> {
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
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            s.alert_publish,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.alert.title,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                s.alert_publish_duration,
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
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => widget.onPublish(_durationSeconds),
            icon: const Icon(Icons.play_circle_outline),
            label: Text(s.alert_publish),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A3C34),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
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
