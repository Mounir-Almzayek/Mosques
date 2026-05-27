import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/app_language.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../../../language/bloc/language/language_bloc.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../widgets/common/common_widgets.dart';

class PrayerIqamaSection extends StatefulWidget {
  final MosqueModel mosque;

  const PrayerIqamaSection({super.key, required this.mosque});

  @override
  State<PrayerIqamaSection> createState() => _PrayerIqamaSectionState();
}

class _PrayerIqamaSectionState extends State<PrayerIqamaSection> {
  late String _calculationMethod;

  final List<String> _methods = [
    'MuslimWorldLeague',
    'Egyptian',
    'Karachi',
    'UmmAlQura',
    'Dubai',
    'Qatar',
    'Kuwait',
    'MoonsightingCommittee',
    'Singapore',
    'Turkey',
    'Tehran',
    'Isna',
  ];

  @override
  void initState() {
    super.initState();
    _calculationMethod = widget.mosque.prayerCalculationMethod;
    if (!_methods.contains(_calculationMethod)) {
      _methods.add(_calculationMethod);
    }
  }

  @override
  void didUpdateWidget(covariant PrayerIqamaSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mosque != widget.mosque) {
      _calculationMethod = widget.mosque.prayerCalculationMethod;
      if (!_methods.contains(_calculationMethod)) {
        _methods.add(_calculationMethod);
      }
    }
  }

  void _save() {
    final bloc = context.read<SettingsBloc>();
    bloc.add(const SaveGeneralSettingsRequested());
    bloc.add(const SaveIqamaSettingsRequested());
    bloc.add(const SaveDesignSettingsRequested());
  }

  Widget _sectionHeader(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SettingsBloc>();
    final s = S.of(context);
    final offsets = widget.mosque.prayerOffsets;
    final iqama = widget.mosque.iqamaSettings;
    final design = widget.mosque.designSettings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Prayer Calculation ──────────────────────────────────────────
        _sectionHeader(context, Icons.calculate_outlined, s.prayer_calculation_method),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey<String>(
            '${widget.mosque.id}_${widget.mosque.prayerCalculationMethod}',
          ),
          initialValue: _calculationMethod,
          decoration: InputDecoration(labelText: s.prayer_calculation_method),
          items: _methods
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() => _calculationMethod = v);
              bloc.add(GeneralSettingChanged(GeneralField.calculationMethod, v));
            }
          },
        ),
        const SizedBox(height: 12),
        BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, langState) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(s.settings_language),
              trailing: DropdownButton<AppLanguage>(
                value: langState.language,
                items: AppLanguage.values
                    .map(
                      (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    bloc.add(LanguageChanged(v));
                    context.read<LanguageBloc>().add(ChangeLanguage(v));
                  }
                },
              ),
            );
          },
        ),

        const Divider(height: 32),

        // ── Prayer Time Offsets ─────────────────────────────────────────
        _sectionHeader(context, Icons.tune_outlined, s.prayer_offsets_title),
        const SizedBox(height: 12),
        OffsetStepperField(
          label: s.prayer_fajr,
          value: offsets.fajr,
          suffix: s.minutes_short,
          onChanged: (v) => bloc.add(PrayerOffsetChanged(PrayerOffsetField.fajr, v)),
        ),
        OffsetStepperField(
          label: s.prayer_sunrise,
          value: offsets.sunrise,
          suffix: s.minutes_short,
          onChanged: (v) => bloc.add(PrayerOffsetChanged(PrayerOffsetField.sunrise, v)),
        ),
        OffsetStepperField(
          label: s.prayer_dhuhr,
          value: offsets.dhuhr,
          suffix: s.minutes_short,
          onChanged: (v) => bloc.add(PrayerOffsetChanged(PrayerOffsetField.dhuhr, v)),
        ),
        OffsetStepperField(
          label: s.prayer_asr,
          value: offsets.asr,
          suffix: s.minutes_short,
          onChanged: (v) => bloc.add(PrayerOffsetChanged(PrayerOffsetField.asr, v)),
        ),
        OffsetStepperField(
          label: s.prayer_maghrib,
          value: offsets.maghrib,
          suffix: s.minutes_short,
          onChanged: (v) => bloc.add(PrayerOffsetChanged(PrayerOffsetField.maghrib, v)),
        ),
        OffsetStepperField(
          label: s.prayer_isha,
          value: offsets.isha,
          suffix: s.minutes_short,
          onChanged: (v) => bloc.add(PrayerOffsetChanged(PrayerOffsetField.isha, v)),
        ),

        const Divider(height: 32),

        // ── Iqama Offsets ───────────────────────────────────────────────
        _sectionHeader(context, Icons.schedule_outlined, s.tab_iqama),
        const SizedBox(height: 12),
        OffsetStepperField(
          label: s.prayer_fajr,
          value: iqama.fajrOffset,
          suffix: s.minutes_short,
          onChanged: (v) => bloc.add(IqamaOffsetChanged(IqamaField.fajr, v)),
        ),
        OffsetStepperField(
          label: s.prayer_dhuhr,
          value: iqama.dhuhrOffset,
          suffix: s.minutes_short,
          onChanged: (v) => bloc.add(IqamaOffsetChanged(IqamaField.dhuhr, v)),
        ),
        OffsetStepperField(
          label: s.prayer_asr,
          value: iqama.asrOffset,
          suffix: s.minutes_short,
          onChanged: (v) => bloc.add(IqamaOffsetChanged(IqamaField.asr, v)),
        ),
        OffsetStepperField(
          label: s.prayer_maghrib,
          value: iqama.maghribOffset,
          suffix: s.minutes_short,
          onChanged: (v) => bloc.add(IqamaOffsetChanged(IqamaField.maghrib, v)),
        ),
        OffsetStepperField(
          label: s.prayer_isha,
          value: iqama.ishaOffset,
          suffix: s.minutes_short,
          onChanged: (v) => bloc.add(IqamaOffsetChanged(IqamaField.isha, v)),
        ),
        OffsetStepperField(
          label: s.prayer_jummah,
          value: iqama.jummahOffset,
          suffix: s.minutes_short,
          onChanged: (v) => bloc.add(IqamaOffsetChanged(IqamaField.jummah, v)),
        ),

        const Divider(height: 32),

        // ── Display Timing ──────────────────────────────────────────────
        _sectionHeader(context, Icons.timer_outlined, s.display_timing_title),
        const SizedBox(height: 12),
        OffsetStepperField(
          label: s.pre_adhan_minutes,
          value: design.preAdhanMinutes,
          suffix: s.minutes_short,
          onChanged: (v) =>
              bloc.add(DisplayTimingChanged(DisplayTimingField.preAdhanMinutes, v)),
        ),
        OffsetStepperField(
          label: s.adhan_moment_duration,
          value: design.adhanMomentDurationSeconds,
          onChanged: (v) =>
              bloc.add(DisplayTimingChanged(DisplayTimingField.adhanMomentDuration, v)),
        ),

        const SizedBox(height: 24),

        // ── Save button ─────────────────────────────────────────────────
        ElevatedButton(
          onPressed: _save,
          child: Text(s.save_general_settings),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
