import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/app_language.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../language/bloc/language/language_bloc.dart';
import '../../core/widgets/common_widgets.dart';
import '../../design/bloc/design_bloc.dart';
import '../../general/bloc/general_bloc.dart';
import '../bloc/iqama_bloc.dart';

class PrayerIqamaSectionBody extends StatefulWidget {
  const PrayerIqamaSectionBody({super.key});

  @override
  State<PrayerIqamaSectionBody> createState() => _PrayerIqamaSectionBodyState();
}

class _PrayerIqamaSectionBodyState extends State<PrayerIqamaSectionBody> {
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
    if (_methodInitialized) return;

    _calculationMethod = method;
    if (!_methods.contains(_calculationMethod)) {
      _methods.add(_calculationMethod);
    }
    _methodInitialized = true;
  }

  void _save() {
    context.read<GeneralBloc>().add(const SaveGeneralRequested());
    context.read<IqamaBloc>().add(const SaveIqamaRequested());
    context.read<DesignBloc>().add(const SaveDesignRequested());
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
                  SettingsSectionHeader(
                    icon: Icons.calculate_outlined,
                    title: s.prayer_calculation_method,
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
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() => _calculationMethod = value);
                      generalBloc.add(
                        GeneralSettingChanged(
                          GeneralField.calculationMethod,
                          value,
                        ),
                      );
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
                                (language) => DropdownMenuItem(
                                  value: language,
                                  child: Text(language.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            generalBloc.add(LanguageChanged(value));
                            context.read<LanguageBloc>().add(
                              ChangeLanguage(value),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const Divider(height: 32),
                  SettingsSectionHeader(
                    icon: Icons.tune_outlined,
                    title: s.prayer_offsets_title,
                  ),
                  const SizedBox(height: 12),
                  OffsetStepperField(
                    label: s.prayer_fajr,
                    value: offsets.fajr,
                    suffix: s.minutes_short,
                    onChanged: (value) => generalBloc.add(
                      PrayerOffsetChanged(PrayerOffsetField.fajr, value),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_sunrise,
                    value: offsets.sunrise,
                    suffix: s.minutes_short,
                    onChanged: (value) => generalBloc.add(
                      PrayerOffsetChanged(PrayerOffsetField.sunrise, value),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_dhuhr,
                    value: offsets.dhuhr,
                    suffix: s.minutes_short,
                    onChanged: (value) => generalBloc.add(
                      PrayerOffsetChanged(PrayerOffsetField.dhuhr, value),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_asr,
                    value: offsets.asr,
                    suffix: s.minutes_short,
                    onChanged: (value) => generalBloc.add(
                      PrayerOffsetChanged(PrayerOffsetField.asr, value),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_maghrib,
                    value: offsets.maghrib,
                    suffix: s.minutes_short,
                    onChanged: (value) => generalBloc.add(
                      PrayerOffsetChanged(PrayerOffsetField.maghrib, value),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_isha,
                    value: offsets.isha,
                    suffix: s.minutes_short,
                    onChanged: (value) => generalBloc.add(
                      PrayerOffsetChanged(PrayerOffsetField.isha, value),
                    ),
                  ),
                  const Divider(height: 32),
                  SettingsSectionHeader(
                    icon: Icons.schedule_outlined,
                    title: s.tab_iqama,
                  ),
                  const SizedBox(height: 12),
                  OffsetStepperField(
                    label: s.prayer_fajr,
                    value: iqama.fajrOffset,
                    suffix: s.minutes_short,
                    onChanged: (value) => iqamaBloc.add(
                      IqamaOffsetChanged(IqamaField.fajr, value),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_dhuhr,
                    value: iqama.dhuhrOffset,
                    suffix: s.minutes_short,
                    onChanged: (value) => iqamaBloc.add(
                      IqamaOffsetChanged(IqamaField.dhuhr, value),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_asr,
                    value: iqama.asrOffset,
                    suffix: s.minutes_short,
                    onChanged: (value) => iqamaBloc.add(
                      IqamaOffsetChanged(IqamaField.asr, value),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_maghrib,
                    value: iqama.maghribOffset,
                    suffix: s.minutes_short,
                    onChanged: (value) => iqamaBloc.add(
                      IqamaOffsetChanged(IqamaField.maghrib, value),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_isha,
                    value: iqama.ishaOffset,
                    suffix: s.minutes_short,
                    onChanged: (value) => iqamaBloc.add(
                      IqamaOffsetChanged(IqamaField.isha, value),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.prayer_jummah,
                    value: iqama.jummahOffset,
                    suffix: s.minutes_short,
                    onChanged: (value) => iqamaBloc.add(
                      IqamaOffsetChanged(IqamaField.jummah, value),
                    ),
                  ),
                  const Divider(height: 32),
                  SettingsSectionHeader(
                    icon: Icons.timer_outlined,
                    title: s.display_timing_title,
                  ),
                  const SizedBox(height: 12),
                  OffsetStepperField(
                    label: s.pre_adhan_minutes,
                    value: design.preAdhanMinutes,
                    suffix: s.minutes_short,
                    onChanged: (value) => context.read<DesignBloc>().add(
                      DisplayTimingChanged(
                        DisplayTimingField.preAdhanMinutes,
                        value,
                      ),
                    ),
                  ),
                  OffsetStepperField(
                    label: s.adhan_moment_duration,
                    value: design.adhanMomentDurationSeconds,
                    onChanged: (value) => context.read<DesignBloc>().add(
                      DisplayTimingChanged(
                        DisplayTimingField.adhanMomentDuration,
                        value,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
