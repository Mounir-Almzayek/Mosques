import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/mosque_model.dart';
import '../../bloc/settings_bloc.dart';

class IqamaSection extends StatefulWidget {
  final MosqueModel mosque;

  const IqamaSection({super.key, required this.mosque});

  @override
  State<IqamaSection> createState() => _IqamaSectionState();
}

class _IqamaSectionState extends State<IqamaSection> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fajrCtrl;
  late TextEditingController _dhuhrCtrl;
  late TextEditingController _asrCtrl;
  late TextEditingController _maghribCtrl;
  late TextEditingController _ishaCtrl;
  late TextEditingController _jummahCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.mosque.iqamaSettings;
    _fajrCtrl = TextEditingController(text: d.fajrOffset.toString());
    _dhuhrCtrl = TextEditingController(text: d.dhuhrOffset.toString());
    _asrCtrl = TextEditingController(text: d.asrOffset.toString());
    _maghribCtrl = TextEditingController(text: d.maghribOffset.toString());
    _ishaCtrl = TextEditingController(text: d.ishaOffset.toString());
    _jummahCtrl = TextEditingController(text: d.jummahOffset.toString());
  }

  @override
  void didUpdateWidget(covariant IqamaSection oldWidget) {
    if (oldWidget.mosque.iqamaSettings != widget.mosque.iqamaSettings) {
      final d = widget.mosque.iqamaSettings;
      _fajrCtrl.text = d.fajrOffset.toString();
      _dhuhrCtrl.text = d.dhuhrOffset.toString();
      _asrCtrl.text = d.asrOffset.toString();
      _maghribCtrl.text = d.maghribOffset.toString();
      _ishaCtrl.text = d.ishaOffset.toString();
      _jummahCtrl.text = d.jummahOffset.toString();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _fajrCtrl.dispose();
    _dhuhrCtrl.dispose();
    _asrCtrl.dispose();
    _maghribCtrl.dispose();
    _ishaCtrl.dispose();
    _jummahCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      context.read<SettingsBloc>().add(const SaveIqamaSettingsRequested());
    }
  }

  Widget _buildField(
    S s,
    String label,
    TextEditingController controller, {
    required void Function(int) onOffset,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          suffixText: s.minutes_suffix,
        ),
        validator: (v) => v!.isEmpty ? s.required_field : null,
        onChanged: (v) {
          final n = int.tryParse(v);
          if (n != null) onOffset(n);
        },
      ),
    );
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
          Text(
            s.iqama_minutes_after_adhan,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildField(
            s,
            s.prayer_fajr,
            _fajrCtrl,
            onOffset: (n) => bloc.add(SettingsIqamaFajrOffsetChanged(n)),
          ),
          _buildField(
            s,
            s.prayer_dhuhr,
            _dhuhrCtrl,
            onOffset: (n) => bloc.add(SettingsIqamaDhuhrOffsetChanged(n)),
          ),
          _buildField(
            s,
            s.prayer_asr,
            _asrCtrl,
            onOffset: (n) => bloc.add(SettingsIqamaAsrOffsetChanged(n)),
          ),
          _buildField(
            s,
            s.prayer_maghrib,
            _maghribCtrl,
            onOffset: (n) => bloc.add(SettingsIqamaMaghribOffsetChanged(n)),
          ),
          _buildField(
            s,
            s.prayer_isha,
            _ishaCtrl,
            onOffset: (n) => bloc.add(SettingsIqamaIshaOffsetChanged(n)),
          ),
          _buildField(
            s,
            s.prayer_jummah,
            _jummahCtrl,
            onOffset: (n) => bloc.add(SettingsIqamaJummahOffsetChanged(n)),
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
