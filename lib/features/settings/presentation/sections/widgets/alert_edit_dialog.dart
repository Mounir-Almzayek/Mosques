import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../data/models/mosque/announcement_model.dart';

class AlertEditDialog extends StatefulWidget {
  final void Function(AnnouncementModel) onAdd;

  const AlertEditDialog({super.key, required this.onAdd});

  @override
  State<AlertEditDialog> createState() => _AlertEditDialogState();
}

class _AlertEditDialogState extends State<AlertEditDialog> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  int _seconds = 30;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      title: Text(s.alert_editor_title),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(labelText: s.alert_field_headline),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentCtrl,
              decoration: InputDecoration(labelText: s.alert_field_message),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(s.alert_field_duration),
                Expanded(
                  child: Slider(
                    value: _seconds.toDouble(),
                    min: 10,
                    max: 600,
                    divisions: 59,
                    onChanged: (v) => setState(() => _seconds = v.toInt()),
                  ),
                ),
                Text('$_seconds ${s.unit_seconds}'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_titleCtrl.text.isNotEmpty && _contentCtrl.text.isNotEmpty) {
              final now = DateTime.now();
              final alert = AnnouncementModel(
                id: const Uuid().v4(),
                title: _titleCtrl.text,
                subtitle: _contentCtrl.text,
                startDate: now,
                endDate: now.add(const Duration(hours: 4)), // Temporary alert
                isPriority: true,
                displayDurationSeconds: _seconds,
                isActive: true,
              );
              widget.onAdd(alert);
              Navigator.pop(context);
            }
          },
          child: Text(s.alert_send_action),
        ),
      ],
    );
  }
}
