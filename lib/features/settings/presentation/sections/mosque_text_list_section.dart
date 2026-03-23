import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../data/models/mosque_model.dart';
import '../../bloc/settings_bloc.dart';

class _MosqueTextL10n {
  const _MosqueTextL10n({
    required this.fabAdd,
    required this.editorNew,
    required this.editorEdit,
    required this.narratorLabel,
    required this.textLabel,
    required this.sourceLabel,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.deleteTitle,
    required this.deleteBody,
    required this.saveBarHint,
    required this.emptyIcon,
  });

  final String fabAdd;
  final String editorNew;
  final String editorEdit;
  final String narratorLabel;
  final String textLabel;
  final String sourceLabel;
  final String emptyTitle;
  final String emptySubtitle;
  final String deleteTitle;
  final String deleteBody;
  final String saveBarHint;
  final IconData emptyIcon;

  static _MosqueTextL10n of(S s, MosqueTextListKind kind) {
    switch (kind) {
      case MosqueTextListKind.hadith:
        return _MosqueTextL10n(
          fabAdd: s.hadith_fab_add,
          editorNew: s.hadith_editor_title_new,
          editorEdit: s.hadith_editor_title_edit,
          narratorLabel: s.hadith_narrator,
          textLabel: s.hadith_text,
          sourceLabel: s.hadith_source,
          emptyTitle: s.hadith_empty_title,
          emptySubtitle: s.hadith_empty_subtitle,
          deleteTitle: s.hadith_delete_title,
          deleteBody: s.hadith_delete_body,
          saveBarHint: s.hadith_save_bar_hint,
          emptyIcon: Icons.menu_book_rounded,
        );
      case MosqueTextListKind.verse:
        return _MosqueTextL10n(
          fabAdd: s.verse_fab_add,
          editorNew: s.verse_editor_title_new,
          editorEdit: s.verse_editor_title_edit,
          narratorLabel: s.verse_narrator,
          textLabel: s.verse_text,
          sourceLabel: s.verse_source,
          emptyTitle: s.verse_empty_title,
          emptySubtitle: s.verse_empty_subtitle,
          deleteTitle: s.verse_delete_title,
          deleteBody: s.verse_delete_body,
          saveBarHint: s.verse_save_bar_hint,
          emptyIcon: Icons.format_quote_rounded,
        );
      case MosqueTextListKind.dua:
        return _MosqueTextL10n(
          fabAdd: s.dua_fab_add,
          editorNew: s.dua_editor_title_new,
          editorEdit: s.dua_editor_title_edit,
          narratorLabel: s.dua_narrator,
          textLabel: s.dua_text,
          sourceLabel: s.dua_source,
          emptyTitle: s.dua_empty_title,
          emptySubtitle: s.dua_empty_subtitle,
          deleteTitle: s.dua_delete_title,
          deleteBody: s.dua_delete_body,
          saveBarHint: s.dua_save_bar_hint,
          emptyIcon: Icons.favorite_border_rounded,
        );
      case MosqueTextListKind.adhkar:
        return _MosqueTextL10n(
          fabAdd: s.adhkar_fab_add,
          editorNew: s.adhkar_editor_title_new,
          editorEdit: s.adhkar_editor_title_edit,
          narratorLabel: s.adhkar_narrator,
          textLabel: s.adhkar_text,
          sourceLabel: s.adhkar_source,
          emptyTitle: s.adhkar_empty_title,
          emptySubtitle: s.adhkar_empty_subtitle,
          deleteTitle: s.adhkar_delete_title,
          deleteBody: s.adhkar_delete_body,
          saveBarHint: s.adhkar_save_bar_hint,
          emptyIcon: Icons.psychology_outlined,
        );
    }
  }
}

/// إدارة قوائم النصوص (حديث، آية، دعاء، ذكر) بنفس أسلوب القائمة والحفظ.
class MosqueTextListSection extends StatefulWidget {
  final MosqueModel mosque;
  final MosqueTextListKind kind;

  const MosqueTextListSection({
    super.key,
    required this.mosque,
    required this.kind,
  });

  @override
  State<MosqueTextListSection> createState() => _MosqueTextListSectionState();
}

class _MosqueTextListSectionState extends State<MosqueTextListSection> {
  void _save() {
    context.read<SettingsBloc>().add(SaveMosqueTextListRequested(widget.kind));
  }

  Future<void> _openEditor([MosqueTextEntryModel? existing]) async {
    final bloc = context.read<SettingsBloc>();
    final s = S.of(context);
    final labels = _MosqueTextL10n.of(s, widget.kind);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _MosqueTextEditorSheet(
        existing: existing,
        bloc: bloc,
        kind: widget.kind,
        labels: labels,
      ),
    );
  }

  Future<void> _confirmDelete(MosqueTextEntryModel item) async {
    final s = S.of(context);
    final labels = _MosqueTextL10n.of(s, widget.kind);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(labels.deleteTitle),
        content: Text(labels.deleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.delete)),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<SettingsBloc>().add(SettingsMosqueTextRemoved(widget.kind, item.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final labels = _MosqueTextL10n.of(s, widget.kind);
    final items = widget.mosque.listByKind(widget.kind);

    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (items.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(labels.emptyIcon, size: 72, color: scheme.outlineVariant),
                        const SizedBox(height: 16),
                        Text(
                          labels.emptyTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          labels.emptySubtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
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
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final h = items[index];
                    return Material(
                      elevation: 0,
                      color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openEditor(h),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      h.narrator.isNotEmpty ? h.narrator : '—',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: s.edit,
                                    icon: Icon(Icons.edit_outlined, color: scheme.primary, size: 22),
                                    onPressed: () => _openEditor(h),
                                  ),
                                  IconButton(
                                    tooltip: s.delete,
                                    icon: Icon(Icons.delete_outline_rounded, color: scheme.error, size: 22),
                                    onPressed: () => _confirmDelete(h),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                h.text,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (h.source.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  h.source,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                              ],
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
                      labels.saveBarHint,
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
            heroTag: 'settings_mosque_text_fab_${widget.kind.name}',
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add_rounded),
            label: Text(labels.fabAdd),
          ),
        ),
      ],
    );
  }
}

class _MosqueTextEditorSheet extends StatefulWidget {
  const _MosqueTextEditorSheet({
    required this.existing,
    required this.bloc,
    required this.kind,
    required this.labels,
  });

  final MosqueTextEntryModel? existing;
  final SettingsBloc bloc;
  final MosqueTextListKind kind;
  final _MosqueTextL10n labels;

  @override
  State<_MosqueTextEditorSheet> createState() => _MosqueTextEditorSheetState();
}

class _MosqueTextEditorSheetState extends State<_MosqueTextEditorSheet> {
  late final TextEditingController _narratorCtrl;
  late final TextEditingController _textCtrl;
  late final TextEditingController _sourceCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _narratorCtrl = TextEditingController(text: e?.narrator ?? '');
    _textCtrl = TextEditingController(text: e?.text ?? '');
    _sourceCtrl = TextEditingController(text: e?.source ?? '');
  }

  @override
  void dispose() {
    _narratorCtrl.dispose();
    _textCtrl.dispose();
    _sourceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final existing = widget.existing;
    final bloc = widget.bloc;
    final labels = widget.labels;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              existing == null ? labels.editorNew : labels.editorEdit,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _narratorCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: labels.narratorLabel,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _textCtrl,
              minLines: 4,
              maxLines: 10,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: labels.textLabel,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _sourceCtrl,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: labels.sourceLabel,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                if (_textCtrl.text.trim().isEmpty) return;
                final item = MosqueTextEntryModel(
                  id: existing?.id ?? const Uuid().v4(),
                  narrator: _narratorCtrl.text.trim(),
                  text: _textCtrl.text.trim(),
                  source: _sourceCtrl.text.trim(),
                );
                if (existing == null) {
                  bloc.add(SettingsMosqueTextAdded(widget.kind, item));
                } else {
                  bloc.add(SettingsMosqueTextUpdated(widget.kind, item));
                }
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_rounded),
              label: Text(s.save),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
