import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../data/models/platform_announcements/settings_announcement_model.dart';
import '../../../../data/repositories/interfaces/platform_announcements_repository_interface.dart';
import '../bloc/general_bloc.dart';
import 'general_coordinates_section.dart';
import 'settings_announcements_slider.dart';

class GeneralSectionBody extends StatefulWidget {
  const GeneralSectionBody({super.key});

  @override
  State<GeneralSectionBody> createState() => _GeneralSectionBodyState();
}

class _GeneralSectionBodyState extends State<GeneralSectionBody> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late final Stream<List<SettingsAnnouncementModel>>
  _settingsAnnouncementsStream;
  bool _locating = false;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _cityController = TextEditingController();
    _settingsAnnouncementsStream = sl<IPlatformAnnouncementsRepository>()
        .watchSettingsAnnouncements();
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
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        UnifiedSnackbar.warning(context, message: s.location_permission_denied);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      bloc.add(
        CoordinatesChanged(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
      UnifiedSnackbar.success(context, message: s.location_updated);
    } catch (e) {
      if (!mounted) return;
      UnifiedSnackbar.error(context, message: s.location_unavailable);
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
                StreamBuilder<List<SettingsAnnouncementModel>>(
                  stream: _settingsAnnouncementsStream,
                  builder: (context, snapshot) {
                    final announcements =
                        snapshot.data ?? const <SettingsAnnouncementModel>[];
                    if (announcements.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SettingsAnnouncementsSlider(
                          announcements: announcements,
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: s.mosque_name_label),
                  validator: (value) =>
                      value!.isEmpty ? s.required_field : null,
                  onChanged: (value) =>
                      bloc.add(GeneralSettingChanged(GeneralField.name, value)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(labelText: s.city_label),
                  validator: (value) =>
                      value!.isEmpty ? s.required_field : null,
                  onChanged: (value) =>
                      bloc.add(GeneralSettingChanged(GeneralField.city, value)),
                ),
                const SizedBox(height: 16),
                GeneralCoordinatesSection(
                  latitude: mosque.latitude,
                  longitude: mosque.longitude,
                  locating: _locating,
                  onUseCurrentLocation: _useCurrentLocation,
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
