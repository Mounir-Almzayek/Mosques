import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../../core/widgets/duration_counter_field.dart';

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
  late int _durationSeconds = widget.alert.publishDurationSeconds;

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
          DurationCounterField(
            label: s.alert_publish_duration,
            value: _durationSeconds,
            step: 10,
            min: 10,
            suffix: s.album_seconds_suffix,
            onChanged: (v) => setState(() => _durationSeconds = v),
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
