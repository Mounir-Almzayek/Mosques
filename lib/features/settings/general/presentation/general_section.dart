import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../bloc/general_bloc.dart';

class GeneralSection extends StatelessWidget {
  const GeneralSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GeneralBloc>(
      create: (_) =>
          GeneralBloc(mosqueRepository: sl<IMosqueRepository>())
            ..add(const LoadGeneral()),
      child: const _GeneralSectionBody(),
    );
  }
}

class _GeneralSectionBody extends StatefulWidget {
  const _GeneralSectionBody();

  @override
  State<_GeneralSectionBody> createState() => _GeneralSectionBodyState();
}

class _GeneralSectionBodyState extends State<_GeneralSectionBody> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  bool _locating = false;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _cityController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _syncControllers(GeneralState state) {
    if (!_controllersInitialized && state.mosque != null) {
      _nameController.text = state.mosque!.name;
      _cityController.text = state.mosque!.city;
      _controllersInitialized = true;
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      context.read<GeneralBloc>().add(const SaveGeneralRequested());
    }
  }

  Future<void> _useCurrentLocation() async {
    final s = S.of(context);
    final bloc = context.read<GeneralBloc>();
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
    final s = S.of(context);

    return BlocListener<GeneralBloc, GeneralState>(
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
      child: BlocBuilder<GeneralBloc, GeneralState>(
        builder: (context, state) {
          final mosque = state.mosque;
          if (mosque == null) {
            return const Center(child: CircularProgressIndicator());
          }

          _syncControllers(state);
          final bloc = context.read<GeneralBloc>();

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: s.mosque_name_label),
                  validator: (v) => v!.isEmpty ? s.required_field : null,
                  onChanged: (v) =>
                      bloc.add(GeneralSettingChanged(GeneralField.name, v)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(labelText: s.city_label),
                  validator: (v) => v!.isEmpty ? s.required_field : null,
                  onChanged: (v) =>
                      bloc.add(GeneralSettingChanged(GeneralField.city, v)),
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
                              mosque.latitude.toStringAsFixed(6),
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.longitude_coordinate(
                              mosque.longitude.toStringAsFixed(6),
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
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location, size: 20),
                      label: Text(s.use_current_location),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                AppButton.elevated(
                  label: s.save_general_settings,
                  onPressed: _save,
                  icon: Icons.save_rounded,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
