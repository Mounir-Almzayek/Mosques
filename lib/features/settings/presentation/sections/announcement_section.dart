import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums/settings/announcement_schedule.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../../bloc/settings/settings_bloc.dart';

AnnouncementSchedule _scheduleFor(AnnouncementModel a) {
  final now = DateTime.now();
  if (now.isBefore(a.startDate)) return AnnouncementSchedule.upcoming;
  if (!now.isBefore(a.endDate)) return AnnouncementSchedule.ended;
  return AnnouncementSchedule.active;
}

class AnnouncementSection extends StatefulWidget {
  final MosqueModel mosque;

  const AnnouncementSection({super.key, required this.mosque});

  @override
  State<AnnouncementSection> createState() => _AnnouncementSectionState();
}

class _AnnouncementSectionState extends State<AnnouncementSection> {
  void _save() {
    context.read<SettingsBloc>().add(const SaveAnnouncementsRequested());
  }

  Future<void> _confirmDelete(AnnouncementModel ad) async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.announcement_delete_title),
        content: Text(s.announcement_delete_body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<SettingsBloc>().add(SettingsAnnouncementRemoved(ad.id));
    }
  }

  Future<void> _openEditor([AnnouncementModel? existing]) async {
    final bloc = context.read<SettingsBloc>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) =>
          _AnnouncementEditorSheet(existing: existing, bloc: bloc),
    );
  }

  Widget _statusChip(BuildContext context, AnnouncementSchedule st, S s) {
    final scheme = Theme.of(context).colorScheme;
    late Color bg;
    late Color fg;
    late String label;
    switch (st) {
      case AnnouncementSchedule.active:
        bg = Colors.green.withValues(alpha: 0.15);
        fg = Colors.green.shade800;
        label = s.announcement_status_active;
        break;
      case AnnouncementSchedule.upcoming:
        bg = scheme.primaryContainer.withValues(alpha: 0.7);
        fg = scheme.onPrimaryContainer;
        label = s.announcement_status_upcoming;
        break;
      case AnnouncementSchedule.ended:
        bg = scheme.surfaceContainerHighest;
        fg = scheme.onSurfaceVariant;
        label = s.announcement_status_ended;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ads = widget.mosque.announcements;

    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (ads.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          size: 72,
                          color: scheme.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s.announcement_empty_title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.announcement_empty_subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: ads.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final a = ads[index];
                    final st = _scheduleFor(a);
                    return Material(
                      key: ValueKey('announcement_${a.id}'),
                      elevation: 0,
                      color: scheme.surfaceContainerHighest.withValues(
                        alpha: 0.6,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openEditor(a),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      a.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: a.isActive
                                                ? AppColors.primary
                                                : scheme.outline,
                                          ),
                                    ),
                                  ),
                                  Transform.scale(
                                    scale: 0.8,
                                    child: Switch(
                                      value: a.isActive,
                                      onChanged: (val) {
                                        context.read<SettingsBloc>().add(
                                          SettingsAnnouncementUpdated(
                                            a.copyWith(isActive: val),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  _statusChip(context, st, s),
                                ],
                              ),
                              if (a.subtitle != null &&
                                  a.subtitle!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Opacity(
                                  opacity: a.isActive ? 1.0 : 0.6,
                                  child: Text(
                                    a.subtitle!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Opacity(
                                opacity: a.isActive ? 1.0 : 0.6,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.date_range_outlined,
                                      size: 16,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '${a.startDate.toLocal().toString().split(' ').first} → ${a.endDate.toLocal().toString().split(' ').first}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _openEditor(a),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                    ),
                                    label: Text(s.edit),
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _confirmDelete(a),
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: scheme.error,
                                    ),
                                    label: Text(
                                      s.delete,
                                      style: TextStyle(color: scheme.error),
                                    ),
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: scheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.announcement_save_bar_hint,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.cloud_upload_rounded),
                        label: Text(s.save),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 120,
          child: FloatingActionButton.extended(
            heroTag: 'settings_announcement_fab',
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add_rounded),
            label: Text(s.announcement_fab_add),
          ),
        ),
      ],
    );
  }
}

class _AnnouncementEditorSheet extends StatefulWidget {
  const _AnnouncementEditorSheet({required this.existing, required this.bloc});

  final AnnouncementModel? existing;
  final SettingsBloc bloc;

  @override
  State<_AnnouncementEditorSheet> createState() =>
      _AnnouncementEditorSheetState();
}

class _AnnouncementEditorSheetState extends State<_AnnouncementEditorSheet> {
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
                  bloc.add(SettingsAnnouncementAdded(newAd));
                } else {
                  bloc.add(SettingsAnnouncementUpdated(newAd));
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

