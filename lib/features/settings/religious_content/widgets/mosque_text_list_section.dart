import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../bloc/religious_content_bloc.dart';
import 'mosque_text_editor_sheet.dart';

class MosqueTextL10n {
  const MosqueTextL10n({
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

  static MosqueTextL10n of(S s, MosqueTextListKind kind) {
    switch (kind) {
      case MosqueTextListKind.hadith:
        return MosqueTextL10n(
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
        return MosqueTextL10n(
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
        return MosqueTextL10n(
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
        return MosqueTextL10n(
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

/// Manages mosque text lists (hadith, verse, dua, adhkar) with the same list
/// and save pattern.
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
  Future<void> _openEditor([MosqueTextEntryModel? existing]) async {
    final bloc = context.read<ReligiousContentBloc>();
    final s = S.of(context);
    final labels = MosqueTextL10n.of(s, widget.kind);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => MosqueTextEditorSheet(
        existing: existing,
        bloc: bloc,
        kind: widget.kind,
        labels: labels,
      ),
    );
  }

  Future<void> _confirmDelete(MosqueTextEntryModel item) async {
    final s = S.of(context);
    final labels = MosqueTextL10n.of(s, widget.kind);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(labels.deleteTitle),
        content: Text(labels.deleteBody),
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
      context.read<ReligiousContentBloc>().add(
            MosqueTextRemoved(widget.kind, item.id),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final labels = MosqueTextL10n.of(s, widget.kind);
    final items = widget.mosque.listByKind(widget.kind);

    return Column(
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
                    Icon(
                      labels.emptyIcon,
                      size: 72,
                      color: scheme.outlineVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      labels.emptyTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels.emptySubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final h = items[index];
                return Material(
                  key: ValueKey('mosque_text_${h.id}'),
                  elevation: 0,
                  color: scheme.surfaceContainerHighest.withValues(
                    alpha: 0.6,
                  ),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  h.narrator.isNotEmpty ? h.narrator : '—',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: h.isActive
                                            ? AppColors.primary
                                            : scheme.outline,
                                      ),
                                ),
                              ),
                              Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: h.isActive,
                                  onChanged: (val) {
                                    context
                                        .read<ReligiousContentBloc>()
                                        .add(
                                          MosqueTextUpdated(
                                            widget.kind,
                                            h.copyWith(isActive: val),
                                          ),
                                        );
                                  },
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: s.edit,
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: scheme.primary,
                                  size: 20,
                                ),
                                onPressed: () => _openEditor(h),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: s.delete,
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: scheme.error,
                                  size: 20,
                                ),
                                onPressed: () => _confirmDelete(h),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Opacity(
                            opacity: h.isActive ? 1.0 : 0.6,
                            child: Text(
                              h.text,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontStyle: h.isActive
                                        ? FontStyle.normal
                                        : FontStyle.italic,
                                  ),
                            ),
                          ),
                          if (h.source.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Opacity(
                              opacity: h.isActive ? 1.0 : 0.6,
                              child: Text(
                                h.source,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontStyle: FontStyle.italic,
                                    ),
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
      ],
    );
  }
}
