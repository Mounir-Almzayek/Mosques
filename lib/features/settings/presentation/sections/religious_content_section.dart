import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../widgets/common/common_widgets.dart';
import 'widgets/content_panel.dart';

class ReligiousContentSection extends StatelessWidget {
  final MosqueModel mosque;

  const ReligiousContentSection({super.key, required this.mosque});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final design = mosque.designSettings;
    final bloc = context.read<SettingsBloc>();
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timing Controls ──────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.timer_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                s.religious_content_timing,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              DisplayTimingChanged(DisplayTimingField.religiousContentWait, v),
            ),
          ),
          OffsetStepperField(
            label: s.religious_content_display,
            value: design.religiousContentDisplaySeconds,
            suffix: s.minutes_short,
            onChanged: (v) => bloc.add(
              DisplayTimingChanged(
                DisplayTimingField.religiousContentDisplay,
                v,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Accordion panels ─────────────────────────────────────────
          ContentPanel(
            mosque: mosque,
            kind: MosqueTextListKind.hadith,
            icon: Icons.menu_book_rounded,
            title: s.tab_hadith,
            scheme: scheme,
          ),
          const SizedBox(height: 8),
          ContentPanel(
            mosque: mosque,
            kind: MosqueTextListKind.verse,
            icon: Icons.format_quote_rounded,
            title: s.tab_verses,
            scheme: scheme,
          ),
          const SizedBox(height: 8),
          ContentPanel(
            mosque: mosque,
            kind: MosqueTextListKind.dua,
            icon: Icons.favorite_border_rounded,
            title: s.tab_duas,
            scheme: scheme,
          ),
          const SizedBox(height: 8),
          ContentPanel(
            mosque: mosque,
            kind: MosqueTextListKind.adhkar,
            icon: Icons.psychology_outlined,
            title: s.tab_adhkar,
            scheme: scheme,
          ),
          const SizedBox(height: 24),

          // ── Save button (timing only) ─────────────────────────────────
          ElevatedButton.icon(
            onPressed: () => bloc.add(const SaveDesignSettingsRequested()),
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
  }
}

