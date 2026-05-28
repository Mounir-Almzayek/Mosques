import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../data/models/mosque/mosque_model.dart';
import '../bloc/settings/settings_bloc.dart';

class AnnouncementEditorSheet extends StatefulWidget {
  const AnnouncementEditorSheet({super.key, required this.existing, required this.bloc});

  final AnnouncementModel? existing;
  final SettingsBloc bloc;

  @override
  State<AnnouncementEditorSheet> createState() =>
      _AnnouncementEditorSheetState();
}

class _AnnouncementEditorSheetState extends State<AnnouncementEditorSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _subtitleCtrl;
  late final TextEditingController _qrCtrl;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _subtitleCtrl = TextEditingController(text: e?.subtitle ?? '');
    _qrCtrl = TextEditingController(text: e?.qrCodeUrl ?? '');
    _startDate = e?.startDate ?? DateTime.now();
    _endDate = e?.endDate ?? DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _qrCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final existing = widget.existing;
    final bloc = widget.bloc;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              existing == null
                  ? s.announcement_editor_new
                  : s.announcement_editor_edit,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: s.announcement_field_title,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _subtitleCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: s.announcement_field_subtitle,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _qrCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: s.announcement_field_qr,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              s.announcement_period,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (d != null) setState(() => _startDate = d);
                    },
                    icon: const Icon(Icons.event_outlined, size: 20),
                    label: Text(
                      _startDate.toLocal().toString().split(' ').first,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime(2035),
                      );
                      if (d != null) setState(() => _endDate = d);
                    },
                    icon: const Icon(Icons.event_available_outlined, size: 20),
                    label: Text(
                      _endDate.toLocal().toString().split(' ').first,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                if (_titleCtrl.text.trim().isEmpty) return;
                if (_endDate.isBefore(_startDate)) {
                  UnifiedSnackbar.warning(
                    context,
                    message: s.announcement_dates_invalid,
                  );
                  return;
                }
                final newAd = AnnouncementModel(
                  id: existing?.id ?? const Uuid().v4(),
                  title: _titleCtrl.text.trim(),
                  subtitle: _subtitleCtrl.text.trim().isEmpty
                      ? null
                      : _subtitleCtrl.text.trim(),
                  qrCodeUrl: _qrCtrl.text.trim().isEmpty
                      ? null
                      : _qrCtrl.text.trim(),
                  startDate: _startDate,
                  endDate: _endDate,
                  isActive: existing?.isActive ?? true,
                  order: existing?.order ?? 0,
                  isPriority: existing?.isPriority ?? false,
                  displayDurationSeconds:
                      existing?.displayDurationSeconds ?? 30,
                );
                if (existing == null) {
                  bloc.add(AnnouncementAdded(newAd));
                } else {
                  bloc.add(AnnouncementUpdated(newAd));
                }
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_rounded),
              label: Text(s.save),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
