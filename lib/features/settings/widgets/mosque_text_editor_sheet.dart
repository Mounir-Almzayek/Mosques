import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../data/models/mosque/mosque_model.dart';
import '../bloc/settings/settings_bloc.dart';
import '../presentation/sections/mosque_text_list_section.dart';

class MosqueTextEditorSheet extends StatefulWidget {
  const MosqueTextEditorSheet({
    super.key,
    required this.existing,
    required this.bloc,
    required this.kind,
    required this.labels,
  });

  final MosqueTextEntryModel? existing;
  final SettingsBloc bloc;
  final MosqueTextListKind kind;
  final MosqueTextL10n labels;

  @override
  State<MosqueTextEditorSheet> createState() => _MosqueTextEditorSheetState();
}

class _MosqueTextEditorSheetState extends State<MosqueTextEditorSheet> {
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
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              existing == null ? labels.editorNew : labels.editorEdit,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _narratorCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: labels.narratorLabel,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _sourceCtrl,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: labels.sourceLabel,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
                  isActive: existing?.isActive ?? true,
                  order: existing?.order ?? 0,
                );
                if (existing == null) {
                  bloc.add(MosqueTextAdded(widget.kind, item));
                } else {
                  bloc.add(MosqueTextUpdated(widget.kind, item));
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
