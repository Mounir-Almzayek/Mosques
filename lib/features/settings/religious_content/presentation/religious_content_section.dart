import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../core/widgets/common_widgets.dart';
import '../bloc/religious_content_bloc.dart';
import '../widgets/content_panel.dart';
import '../widgets/mosque_text_editor_sheet.dart';
import '../widgets/mosque_text_list_section.dart';

class ReligiousContentSection extends StatelessWidget {
  const ReligiousContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReligiousContentBloc>(
      create: (_) =>
          ReligiousContentBloc(mosqueRepository: sl<IMosqueRepository>())
            ..add(const LoadReligiousContent()),
      child: const _ReligiousContentSectionBody(),
    );
  }
}

class _ReligiousContentSectionBody extends StatelessWidget {
  const _ReligiousContentSectionBody();

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
          final design = mosque.designSettings;
          final scheme = Theme.of(context).colorScheme;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Timing Controls ──────────────────────────────────────
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s.religious_content_timing,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OffsetStepperField(
                  label: s.religious_content_wait,
                  value: design.religiousContentWaitSeconds,
                  suffix: s.minutes_short,
                  onChanged: (v) => bloc.add(
                    ReligiousContentTimingChanged(
                      ReligiousContentTimingField.wait,
                      v,
                    ),
                  ),
                ),
                OffsetStepperField(
                  label: s.religious_content_display,
                  value: design.religiousContentDisplaySeconds,
                  suffix: s.minutes_short,
                  onChanged: (v) => bloc.add(
                    ReligiousContentTimingChanged(
                      ReligiousContentTimingField.display,
                      v,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Accordion panels ─────────────────────────────────────
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

                // ── Save button (timing + all text lists) ────────────────
                ElevatedButton.icon(
                  onPressed: () {
                    bloc.add(const SaveAllReligiousContentRequested());
                  },
                  icon: const Icon(Icons.cloud_upload_rounded),
                  label: Text(S.of(context).save),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
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
