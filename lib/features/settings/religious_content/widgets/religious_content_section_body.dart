import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/settings/mosque_text_list_kind.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../bloc/religious_content_bloc.dart';
import 'content_panel.dart';
import 'mosque_text_editor_sheet.dart';
import 'mosque_text_list_section.dart';
import 'religious_content_timing_section.dart';

class ReligiousContentSectionBody extends StatelessWidget {
  const ReligiousContentSectionBody({super.key});

  void _openEditorForKind(BuildContext context, MosqueTextListKind kind) {
    final bloc = context.read<ReligiousContentBloc>();
    final s = S.of(context);
    final labels = MosqueTextL10n.of(s, kind);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => MosqueTextEditorSheet(
        existing: null,
        bloc: bloc,
        kind: kind,
        labels: labels,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<ReligiousContentBloc, ReligiousContentState>(
      listenWhen: (prev, curr) =>
          prev.isSaving != curr.isSaving ||
          (curr.error != null && prev.error == null),
      listener: (context, state) {
        if (state.isSaving) {
          UnifiedSnackbar.info(context, message: s.saving);
        } else if (state.error != null) {
          UnifiedSnackbar.error(context, message: state.error!);
        } else {
          UnifiedSnackbar.hide(context);
          UnifiedSnackbar.success(context, message: s.saved_successfully);
        }
      },
      child: BlocBuilder<ReligiousContentBloc, ReligiousContentState>(
        builder: (context, state) {
          final mosque = state.mosque;
          if (mosque == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final bloc = context.read<ReligiousContentBloc>();
          final design = mosque.displaySettings;
          final scheme = Theme.of(context).colorScheme;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReligiousContentTimingSection(
                  design: design,
                  title: s.religious_content_timing,
                  waitLabel: s.religious_content_wait,
                  displayLabel: s.religious_content_display,
                  suffix: s.minutes_short,
                  onWaitChanged: (value) => bloc.add(
                    ReligiousContentTimingChanged(
                      ReligiousContentTimingField.wait,
                      value,
                    ),
                  ),
                  onDisplayChanged: (value) => bloc.add(
                    ReligiousContentTimingChanged(
                      ReligiousContentTimingField.display,
                      value,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ContentPanel(
                  mosque: mosque,
                  kind: MosqueTextListKind.hadith,
                  icon: Icons.menu_book_rounded,
                  title: s.tab_hadith,
                  scheme: scheme,
                  onAddPressed: () =>
                      _openEditorForKind(context, MosqueTextListKind.hadith),
                ),
                const SizedBox(height: 8),
                ContentPanel(
                  mosque: mosque,
                  kind: MosqueTextListKind.verse,
                  icon: Icons.format_quote_rounded,
                  title: s.tab_verses,
                  scheme: scheme,
                  onAddPressed: () =>
                      _openEditorForKind(context, MosqueTextListKind.verse),
                ),
                const SizedBox(height: 8),
                ContentPanel(
                  mosque: mosque,
                  kind: MosqueTextListKind.dua,
                  icon: Icons.favorite_border_rounded,
                  title: s.tab_duas,
                  scheme: scheme,
                  onAddPressed: () =>
                      _openEditorForKind(context, MosqueTextListKind.dua),
                ),
                const SizedBox(height: 8),
                ContentPanel(
                  mosque: mosque,
                  kind: MosqueTextListKind.adhkar,
                  icon: Icons.psychology_outlined,
                  title: s.tab_adhkar,
                  scheme: scheme,
                  onAddPressed: () =>
                      _openEditorForKind(context, MosqueTextListKind.adhkar),
                ),
                const SizedBox(height: 24),
                AppButton.elevated(
                  label: state.isSaving ? s.saving : s.save,
                  isLoading: state.isSaving,
                  disabled: state.isSaving,
                  onPressed: () {
                    bloc.add(const SaveAllReligiousContentRequested());
                  },
                  leadingIcon: Icons.cloud_upload_rounded,
                  height: 48,
                  borderRadius: 14,
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
