import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/enums/app_language.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../../language/bloc/language/language_bloc.dart';
import '../../bloc/settings/settings_bloc.dart'
    hide
        GeneralSettingChanged,
        GeneralField,
        LanguageChanged,
        CoordinatesChanged,
        PrayerOffsetChanged,
        PrayerOffsetField,
        IqamaOffsetChanged,
        IqamaField;
import '../../core/widgets/common_widgets.dart';
import '../../general/bloc/general_bloc.dart';
import '../bloc/iqama_bloc.dart';

class PrayerIqamaSection extends StatelessWidget {
  const PrayerIqamaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GeneralBloc>(
          create: (_) =>
              GeneralBloc(mosqueRepository: sl<IMosqueRepository>())
                ..add(const LoadGeneral()),
        ),
        BlocProvider<IqamaBloc>(
          create: (_) =>
              IqamaBloc(mosqueRepository: sl<IMosqueRepository>())
                ..add(const LoadIqama()),
        ),
      ],
      child: const _PrayerIqamaSectionBody(),
    );
  }
}

class _PrayerIqamaSectionBody extends StatefulWidget {
  const _PrayerIqamaSectionBody();

  @override
  State<_PrayerIqamaSectionBody> createState() =>
      _PrayerIqamaSectionBodyState();
}

class _PrayerIqamaSectionBodyState extends State<_PrayerIqamaSectionBody> {
  late String _calculationMethod;
  bool _methodInitialized = false;

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
    _calculationMethod = 'MuslimWorldLeague';
  }

  void _syncMethod(String method) {
    if (!_methodInitialized) {
      _calculationMethod = method;
      if (!_methods.contains(_calculationMethod)) {
        _methods.add(_calculationMethod);
      }
      _methodInitialized = true;
    }
  }

  void _save() {
    context.read<GeneralBloc>().add(const SaveGeneralRequested());
    context.read<IqamaBloc>().add(const SaveIqamaRequested());
    // Display timing (preAdhan/adhanMoment) is still saved via the old SettingsBloc
    // until DesignBloc is created. If SettingsBloc is still available, save design too.
    try {
      context.read<SettingsBloc>().add(const SaveDesignSettingsRequested());
    } catch (_) {
      // SettingsBloc not available — design timing will be handled by DesignBloc later.
    }
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
    final s = S.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<GeneralBloc, GeneralState>(
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
        ),
        BlocListener<IqamaBloc, IqamaState>(
          listenWhen: (prev, curr) =>
              prev.isSaving != curr.isSaving ||
              (curr.error != null && prev.error == null),
          listener: (context, state) {
            if (state.error != null) {
              UnifiedSnackbar.error(context, message: state.error!);
            }
          },
        ),
      ],
      child: BlocBuilder<GeneralBloc, GeneralState>(
        builder: (context, generalState) {
          return BlocBuilder<IqamaBloc, IqamaState>(
            builder: (context, iqamaState) {
              // Use general mosque for most data; iqama state for iqama offsets.
              final mosque = generalState.mosque;
              if (mosque == null) {
                return const Center(child: CircularProgressIndicator());
              }

              _syncMethod(mosque.prayerCalculationMethod);

              final generalBloc = context.read<GeneralBloc>();
              final iqamaBloc = context.read<IqamaBloc>();
              final offsets = mosque.prayerOffsets;
              final iqamaMosque = iqamaState.mosque;
              final iqama = iqamaMosque?.iqamaSettings ?? mosque.iqamaSettings;
              final design = mosque.designSettings;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Prayer Calculation ──────────────────────────────────
                  _sectionHeader(
                    context,
                    Icons.calculate_outlined,
                    s.prayer_calculation_method,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey<String>(
                      '${mosque.id}_${mosque.prayerCalculationMethod}',
                    ),
                    initialValue: _calculationMethod,
                    decoration: InputDecoration(
                      labelText: s.prayer_calculation_method,
                    ),
                    items: _methods
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _calculationMethod = v);
                        generalBloc.add(
                          GeneralSettingChanged(
                            GeneralField.calculationMethod,
                            v,
                          ),
                        );
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
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              generalBloc.add(LanguageChanged(v));
                              context
                                  .read<LanguageBloc>()
                                  .add(ChangeLanguage(v));
                            }
                          },
                        ),
                      );
                    },
                  ),

                  const Divider(height: 32),

                  // ── Prayer Time Offsets ─────────────────────────────────
                  _sectionHeader(
                    context,
                    Icons.tune_outlined,
                    s.prayer_offsets_title,
                  ),
                  const SizedBox(height: 12),
                  OffsetStepperField(
                    label: s.prayer_fajr,
                    value: offsets.fajr,
                    suffix: s.minutes_short,
                    onChanged: (v) => generalBloc.add(
                      PrayerOffsetChanged(PrayerOffsetField.fajr, v),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_sunrise,
                    value: offsets.sunrise,
                    suffix: s.minutes_short,
                    onChanged: (v) => generalBloc.add(
                      PrayerOffsetChanged(PrayerOffsetField.sunrise, v),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_dhuhr,
                    value: offsets.dhuhr,
                    suffix: s.minutes_short,
                    onChanged: (v) => generalBloc.add(
                      PrayerOffsetChanged(PrayerOffsetField.dhuhr, v),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_asr,
                    value: offsets.asr,
                    suffix: s.minutes_short,
                    onChanged: (v) => generalBloc.add(
                      PrayerOffsetChanged(PrayerOffsetField.asr, v),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_maghrib,
                    value: offsets.maghrib,
                    suffix: s.minutes_short,
                    onChanged: (v) => generalBloc.add(
                      PrayerOffsetChanged(PrayerOffsetField.maghrib, v),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_isha,
                    value: offsets.isha,
                    suffix: s.minutes_short,
                    onChanged: (v) => generalBloc.add(
                      PrayerOffsetChanged(PrayerOffsetField.isha, v),
                    ),
                  ),

                  const Divider(height: 32),

                  // ── Iqama Offsets ───────────────────────────────────────
                  _sectionHeader(
                    context,
                    Icons.schedule_outlined,
                    s.tab_iqama,
                  ),
                  const SizedBox(height: 12),
                  OffsetStepperField(
                    label: s.prayer_fajr,
                    value: iqama.fajrOffset,
                    suffix: s.minutes_short,
                    onChanged: (v) => iqamaBloc.add(
                      IqamaOffsetChanged(IqamaField.fajr, v),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_dhuhr,
                    value: iqama.dhuhrOffset,
                    suffix: s.minutes_short,
                    onChanged: (v) => iqamaBloc.add(
                      IqamaOffsetChanged(IqamaField.dhuhr, v),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_asr,
                    value: iqama.asrOffset,
                    suffix: s.minutes_short,
                    onChanged: (v) => iqamaBloc.add(
                      IqamaOffsetChanged(IqamaField.asr, v),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_maghrib,
                    value: iqama.maghribOffset,
                    suffix: s.minutes_short,
                    onChanged: (v) => iqamaBloc.add(
                      IqamaOffsetChanged(IqamaField.maghrib, v),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_isha,
                    value: iqama.ishaOffset,
                    suffix: s.minutes_short,
                    onChanged: (v) => iqamaBloc.add(
                      IqamaOffsetChanged(IqamaField.isha, v),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_jummah,
                    value: iqama.jummahOffset,
                    suffix: s.minutes_short,
                    onChanged: (v) => iqamaBloc.add(
                      IqamaOffsetChanged(IqamaField.jummah, v),
                    ),
                  ),

                  const Divider(height: 32),

                  // ── Display Timing ─────────────────────────────────────
                  _sectionHeader(
                    context,
                    Icons.timer_outlined,
                    s.display_timing_title,
                  ),
                  const SizedBox(height: 12),
                  OffsetStepperField(
                    label: s.pre_adhan_minutes,
                    value: design.preAdhanMinutes,
                    suffix: s.minutes_short,
                    onChanged: (v) => context.read<SettingsBloc>().add(
                          DisplayTimingChanged(
                            DisplayTimingField.preAdhanMinutes,
                            v,
                          ),
                        ),
                  ),
                  OffsetStepperField(
                    label: s.adhan_moment_duration,
                    value: design.adhanMomentDurationSeconds,
                    onChanged: (v) => context.read<SettingsBloc>().add(
                          DisplayTimingChanged(
                            DisplayTimingField.adhanMomentDuration,
                            v,
                          ),
                        ),
                  ),

                  const SizedBox(height: 24),

                  // ── Save button ────────────────────────────────────────
                  AppButton.elevated(
                    label: s.save_general_settings,
                    onPressed: _save,
                    icon: Icons.save_rounded,
                  ),

                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
