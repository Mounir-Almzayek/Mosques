import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/enums/app_language.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../../../language/bloc/language/language_bloc.dart';
import '../../bloc/settings/settings_bloc.dart';

import '../widgets/common/common_widgets.dart';

class GeneralSection extends StatefulWidget {
  final MosqueModel mosque;

  const GeneralSection({super.key, required this.mosque});

  @override
  State<GeneralSection> createState() => _GeneralSectionState();
}

class _GeneralSectionState extends State<GeneralSection> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late String _calculationMethod;
  bool _locating = false;

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
    _nameController = TextEditingController(text: widget.mosque.name);
    _cityController = TextEditingController(text: widget.mosque.city);
    _calculationMethod = widget.mosque.prayerCalculationMethod;
    if (!_methods.contains(_calculationMethod)) {
      _methods.add(_calculationMethod);
    }
  }

  @override
  void didUpdateWidget(covariant GeneralSection oldWidget) {
    if (oldWidget.mosque != widget.mosque) {
      _nameController.text = widget.mosque.name;
      _cityController.text = widget.mosque.city;
      _calculationMethod = widget.mosque.prayerCalculationMethod;
      if (!_methods.contains(_calculationMethod)) {
        _methods.add(_calculationMethod);
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      context.read<SettingsBloc>().add(const SaveGeneralSettingsRequested());
    }
  }

  Future<void> _useCurrentLocation() async {
    final s = S.of(context);
    final bloc = context.read<SettingsBloc>();
    setState(() => _locating = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(s.location_permission_denied)));
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      bloc.add(
        SettingsMosqueCoordinatesChanged(
          latitude: pos.latitude,
          longitude: pos.longitude,
        ),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.location_updated)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.location_unavailable)));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SettingsBloc>();
    final s = S.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                      context.read<SettingsBloc>().add(
                        SettingsMosqueLanguageChanged(v),
                      );
                      context.read<LanguageBloc>().add(ChangeLanguage(v));
                    }
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: s.mosque_name_label),
            validator: (v) => v!.isEmpty ? s.required_field : null,
            onChanged: (v) => bloc.add(SettingsMosqueNameChanged(v)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cityController,
            decoration: InputDecoration(labelText: s.city_label),
            validator: (v) => v!.isEmpty ? s.required_field : null,
            onChanged: (v) => bloc.add(SettingsMosqueCityChanged(v)),
          ),
          const SizedBox(height: 16),
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
                bloc.add(SettingsPrayerCalculationMethodChanged(v));
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.latitude_coordinate(
                        widget.mosque.latitude.toStringAsFixed(6),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.longitude_coordinate(
                        widget.mosque.longitude.toStringAsFixed(6),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: _locating ? null : _useCurrentLocation,
                icon: _locating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, size: 20),
                label: Text(s.use_current_location),
              ),
            ],
          ),
          const Divider(height: 32),
          Text(
            s.general_section_adjustments,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          OffsetStepperField(
            label: s.prayer_fajr,
            value: widget.mosque.prayerOffsets.fajr,
            suffix: s.minutes_short,
            onChanged: (v) => bloc.add(SettingsPrayerOffsetFajrChanged(v)),
          ),
          OffsetStepperField(
            label: s.prayer_sunrise,
            value: widget.mosque.prayerOffsets.sunrise,
            suffix: s.minutes_short,
            onChanged: (v) => bloc.add(SettingsPrayerOffsetSunriseChanged(v)),
          ),
          OffsetStepperField(
            label: s.prayer_dhuhr,
            value: widget.mosque.prayerOffsets.dhuhr,
            suffix: s.minutes_short,
            onChanged: (v) => bloc.add(SettingsPrayerOffsetDhuhrChanged(v)),
          ),
          OffsetStepperField(
            label: s.prayer_asr,
            value: widget.mosque.prayerOffsets.asr,
            suffix: s.minutes_short,
            onChanged: (v) => bloc.add(SettingsPrayerOffsetAsrChanged(v)),
          ),
          OffsetStepperField(
            label: s.prayer_maghrib,
            value: widget.mosque.prayerOffsets.maghrib,
            suffix: s.minutes_short,
            onChanged: (v) => bloc.add(SettingsPrayerOffsetMaghribChanged(v)),
          ),
          OffsetStepperField(
            label: s.prayer_isha,
            value: widget.mosque.prayerOffsets.isha,
            suffix: s.minutes_short,
            onChanged: (v) => bloc.add(SettingsPrayerOffsetIshaChanged(v)),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _save(),
            child: Text(s.save_general_settings),
          ),
        ],
      ),
    );
  }
}

