import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../../bloc/settings/settings_bloc.dart';

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
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.mosque.name);
    _cityController = TextEditingController(text: widget.mosque.city);
  }

  @override
  void didUpdateWidget(covariant GeneralSection oldWidget) {
    if (oldWidget.mosque != widget.mosque) {
      _nameController.text = widget.mosque.name;
      _cityController.text = widget.mosque.city;
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
        UnifiedSnackbar.warning(
          context,
          message: s.location_permission_denied,
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      bloc.add(
        CoordinatesChanged(
          latitude: pos.latitude,
          longitude: pos.longitude,
        ),
      );
      UnifiedSnackbar.success(
        context,
        message: s.location_updated,
      );
    } catch (e) {
      if (!mounted) return;
      UnifiedSnackbar.error(
        context,
        message: s.location_unavailable,
      );
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
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: s.mosque_name_label),
            validator: (v) => v!.isEmpty ? s.required_field : null,
            onChanged: (v) => bloc.add(GeneralSettingChanged(GeneralField.name, v)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cityController,
            decoration: InputDecoration(labelText: s.city_label),
            validator: (v) => v!.isEmpty ? s.required_field : null,
            onChanged: (v) => bloc.add(GeneralSettingChanged(GeneralField.city, v)),
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
