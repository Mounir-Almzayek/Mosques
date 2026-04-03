import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../../bloc/settings/settings_bloc.dart';

import '../widgets/common/common_widgets.dart';

class IqamaSection extends StatefulWidget {
  final MosqueModel mosque;

  const IqamaSection({super.key, required this.mosque});

  @override
  State<IqamaSection> createState() => _IqamaSectionState();
}

class _IqamaSectionState extends State<IqamaSection> {
  final _formKey = GlobalKey<FormState>();

  void _save() {
    if (_formKey.currentState!.validate()) {
      context.read<SettingsBloc>().add(const SaveIqamaSettingsRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SettingsBloc>();
    final s = S.of(context);
    final i = widget.mosque.iqamaSettings;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            s.iqama_minutes_after_adhan,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          OffsetStepperField(
            label: s.prayer_fajr,
            value: i.fajrOffset,
            suffix: s.minutes_short,
            onChanged: (n) => bloc.add(SettingsIqamaFajrOffsetChanged(n)),
          ),
          OffsetStepperField(
            label: s.prayer_dhuhr,
            value: i.dhuhrOffset,
            suffix: s.minutes_short,
            onChanged: (n) => bloc.add(SettingsIqamaDhuhrOffsetChanged(n)),
          ),
          OffsetStepperField(
            label: s.prayer_asr,
            value: i.asrOffset,
            suffix: s.minutes_short,
            onChanged: (n) => bloc.add(SettingsIqamaAsrOffsetChanged(n)),
          ),
          OffsetStepperField(
            label: s.prayer_maghrib,
            value: i.maghribOffset,
            suffix: s.minutes_short,
            onChanged: (n) => bloc.add(SettingsIqamaMaghribOffsetChanged(n)),
          ),
          OffsetStepperField(
            label: s.prayer_isha,
            value: i.ishaOffset,
            suffix: s.minutes_short,
            onChanged: (n) => bloc.add(SettingsIqamaIshaOffsetChanged(n)),
          ),
          OffsetStepperField(
            label: s.prayer_jummah,
            value: i.jummahOffset,
            suffix: s.minutes_short,
            onChanged: (n) => bloc.add(SettingsIqamaJummahOffsetChanged(n)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _save(),
            child: Text(s.save_iqama_settings),
          ),
        ],
      ),
    );
  }
}

