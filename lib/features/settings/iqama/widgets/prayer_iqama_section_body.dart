import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../data/models/mosque/mosque_bootstrap.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
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
  String? _previewKey;
  Future<PrayerSettingsPreview>? _previewFuture;

  final List<String> _fallbackMethods = [
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
    _methodInitialized = true;
  }

  String _keyFor(MosqueBootstrap mosque) {
    final p = mosque.prayerSettings;
    return [
      mosque.id,
      p.calculationMethod,
      p.offsets.props.join(','),
      p.iqamaOffsets.props.join(','),
    ].join('|');
  }

  Future<PrayerSettingsPreview> _previewFor(MosqueBootstrap mosque) {
    final key = _keyFor(mosque);
    if (_previewKey == key && _previewFuture != null) return _previewFuture!;
    _previewKey = key;
    _previewFuture = sl<IMosqueRepository>().previewPrayerSettings(mosque);
    return _previewFuture!;
  }

  List<String> _methodsFrom(PrayerSettingsPreview? preview) {
    final fromServer = preview?.methods.map((method) => method.key).toList();
    final methods = fromServer == null || fromServer.isEmpty
        ? List<String>.from(_fallbackMethods)
        : fromServer;
    if (!methods.contains(_calculationMethod)) {
      methods.add(_calculationMethod);
    }
    return methods;
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

              _syncMethod(mosque.prayerSettings.calculationMethod);

              final generalBloc = context.read<GeneralBloc>();
              final iqamaBloc = context.read<IqamaBloc>();
              final offsets = mosque.prayerSettings.offsets;
              final iqamaMosque = iqamaState.mosque;
              final iqama =
                  iqamaMosque?.prayerSettings.iqamaOffsets ??
                  mosque.prayerSettings.iqamaOffsets;
              final previewMosque = mosque.copyWith(
                prayerSettings: mosque.prayerSettings.copyWith(
                  calculationMethod: _calculationMethod,
                  iqamaOffsets: iqama,
                ),
              );

              return FutureBuilder<PrayerSettingsPreview>(
                future: _previewFor(previewMosque),
                builder: (context, previewSnapshot) {
                  final preview = previewSnapshot.data;
                  final methods = _methodsFrom(preview);

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
                          '${mosque.id}_${mosque.prayerSettings.calculationMethod}_${methods.length}',
                        ),
                        initialValue: _calculationMethod,
                        decoration: InputDecoration(
                          labelText: s.prayer_calculation_method,
                        ),
                        items: methods
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
                      const Divider(height: 32),
                      SettingsSectionHeader(
                        icon: Icons.tune_outlined,
                        title: s.prayer_offsets_title,
                      ),
                      const SizedBox(height: 12),
                      _PrayerOffsetField(
                        label: s.prayer_fajr,
                        value: offsets.fajr,
                        previewTime: preview?.itemFor('fajr')?.adhanTime,
                        suffix: s.minutes_short,
                        onChanged: (value) => generalBloc.add(
                          PrayerOffsetChanged(PrayerOffsetField.fajr, value),
                        ),
                      ),
                      _PrayerOffsetField(
                        label: s.prayer_sunrise,
                        value: offsets.sunrise,
                        previewTime: preview?.itemFor('sunrise')?.adhanTime,
                        suffix: s.minutes_short,
                        onChanged: (value) => generalBloc.add(
                          PrayerOffsetChanged(PrayerOffsetField.sunrise, value),
                        ),
                      ),
                      _PrayerOffsetField(
                        label: s.prayer_dhuhr,
                        value: offsets.dhuhr,
                        previewTime: preview?.itemFor('dhuhr')?.adhanTime,
                        suffix: s.minutes_short,
                        onChanged: (value) => generalBloc.add(
                          PrayerOffsetChanged(PrayerOffsetField.dhuhr, value),
                        ),
                      ),
                      _PrayerOffsetField(
                        label: s.prayer_asr,
                        value: offsets.asr,
                        previewTime: preview?.itemFor('asr')?.adhanTime,
                        suffix: s.minutes_short,
                        onChanged: (value) => generalBloc.add(
                          PrayerOffsetChanged(PrayerOffsetField.asr, value),
                        ),
                      ),
                      _PrayerOffsetField(
                        label: s.prayer_maghrib,
                        value: offsets.maghrib,
                        previewTime: preview?.itemFor('maghrib')?.adhanTime,
                        suffix: s.minutes_short,
                        onChanged: (value) => generalBloc.add(
                          PrayerOffsetChanged(PrayerOffsetField.maghrib, value),
                        ),
                      ),
                      _PrayerOffsetField(
                        label: s.prayer_isha,
                        value: offsets.isha,
                        previewTime: preview?.itemFor('isha')?.adhanTime,
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
                      _PrayerOffsetField(
                        label: s.prayer_fajr,
                        value: iqama.fajr,
                        previewTime: preview?.itemFor('fajr')?.iqamaTime,
                        suffix: s.minutes_short,
                        onChanged: (value) => iqamaBloc.add(
                          IqamaOffsetChanged(IqamaField.fajr, value),
                        ),
                      ),
                      _PrayerOffsetField(
                        label: s.prayer_dhuhr,
                        value: iqama.dhuhr,
                        previewTime: preview?.itemFor('dhuhr')?.iqamaTime,
                        suffix: s.minutes_short,
                        onChanged: (value) => iqamaBloc.add(
                          IqamaOffsetChanged(IqamaField.dhuhr, value),
                        ),
                      ),
                      _PrayerOffsetField(
                        label: s.prayer_asr,
                        value: iqama.asr,
                        previewTime: preview?.itemFor('asr')?.iqamaTime,
                        suffix: s.minutes_short,
                        onChanged: (value) => iqamaBloc.add(
                          IqamaOffsetChanged(IqamaField.asr, value),
                        ),
                      ),
                      _PrayerOffsetField(
                        label: s.prayer_maghrib,
                        value: iqama.maghrib,
                        previewTime: preview?.itemFor('maghrib')?.iqamaTime,
                        suffix: s.minutes_short,
                        onChanged: (value) => iqamaBloc.add(
                          IqamaOffsetChanged(IqamaField.maghrib, value),
                        ),
                      ),
                      _PrayerOffsetField(
                        label: s.prayer_isha,
                        value: iqama.isha,
                        previewTime: preview?.itemFor('isha')?.iqamaTime,
                        suffix: s.minutes_short,
                        onChanged: (value) => iqamaBloc.add(
                          IqamaOffsetChanged(IqamaField.isha, value),
                        ),
                      ),
                      _PrayerOffsetField(
                        label: s.prayer_jummah,
                        value: iqama.jummah,
                        previewTime: preview?.itemFor('dhuhr')?.iqamaTime,
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
                      BlocBuilder<DesignBloc, DesignState>(
                        builder: (context, designState) {
                          final prayer =
                              designState.mosque?.prayerSettings ??
                              mosque.prayerSettings;
                          final designBloc = context.read<DesignBloc>();
                          return Column(
                            children: [
                              OffsetStepperField(
                                label: s.pre_adhan_minutes,
                                value: prayer.preAdhanMinutes,
                                suffix: s.minutes_short,
                                onChanged: (value) => designBloc.add(
                                  DisplayTimingChanged(
                                    DisplayTimingField.preAdhanMinutes,
                                    value,
                                  ),
                                ),
                              ),
                              OffsetStepperField(
                                label: s.adhan_moment_duration,
                                value: prayer.adhanMomentDurationSeconds,
                                onChanged: (value) => designBloc.add(
                                  DisplayTimingChanged(
                                    DisplayTimingField.adhanMomentDuration,
                                    value,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
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
          );
        },
      ),
    );
  }
}

class _PrayerOffsetField extends StatelessWidget {
  const _PrayerOffsetField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.suffix,
    this.previewTime,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final String suffix;
  final DateTime? previewTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OffsetStepperField(
          label: label,
          value: value,
          suffix: suffix,
          onChanged: onChanged,
        ),
        if (previewTime != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 8,
              end: 8,
              bottom: 8,
            ),
            child: Text(
              MaterialLocalizations.of(
                context,
              ).formatTimeOfDay(TimeOfDay.fromDateTime(previewTime!.toLocal())),
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
