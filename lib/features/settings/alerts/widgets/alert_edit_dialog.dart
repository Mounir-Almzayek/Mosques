import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../data/models/mosque/announcement_model.dart';

/// Dialog for creating a new alert or editing an existing one.
///
/// When [initialAlert] is provided, the dialog operates in edit mode,
/// pre-filling all fields from the existing alert.
class AlertEditDialog extends StatefulWidget {
  /// Called with the created or updated [AnnouncementModel].
  final void Function(AnnouncementModel) onAdd;

  /// When provided, the dialog pre-fills fields for editing.
  final AnnouncementModel? initialAlert;

  const AlertEditDialog({super.key, required this.onAdd, this.initialAlert});

  @override
  State<AlertEditDialog> createState() => _AlertEditDialogState();
}

class _AlertEditDialogState extends State<AlertEditDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _subtitleCtrl;

  @override
  void initState() {
    super.initState();
    final existing = widget.initialAlert;
    _titleCtrl = TextEditingController(text: existing?.title ?? '');
    _subtitleCtrl = TextEditingController(text: existing?.subtitle ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final existing = widget.initialAlert;
    final now = DateTime.now();
    final alert = AnnouncementModel(
      id: existing?.id ?? const Uuid().v4(),
      title: title,
      subtitle: _subtitleCtrl.text.trim().isEmpty
          ? null
          : _subtitleCtrl.text.trim(),
      startDate: existing?.startDate ?? now,
      endDate: existing?.endDate ?? now.add(const Duration(days: 365)),
      isPriority: true,
      isActive: existing?.isActive ?? true,
      order: existing?.order ?? 0,
      displayDurationSeconds: existing?.displayDurationSeconds ?? 30,
      isPublished: existing?.isPublished ?? false,
      publishedAt: existing?.publishedAt,
      publishDurationSeconds: existing?.publishDurationSeconds ?? 30,
    );

    widget.onAdd(alert);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isEditing = widget.initialAlert != null;

    return AlertDialog(
      title: Text(isEditing ? s.alert_edit : s.alert_create),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: s.alert_field_headline,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _subtitleCtrl,
              textInputAction: TextInputAction.done,
              maxLines: 3,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: s.alert_field_message,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        AppButton.elevated(
          label: isEditing ? s.save : s.alert_create,
          onPressed: _submit,
          height: 40,
          borderRadius: 12,
          backgroundColor: const Color(0xFF1A3C34),
          expand: false,
          useShadow: false,
        ),
      ],
    );
  }
}
