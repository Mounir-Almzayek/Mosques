import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../data/models/administrative_division.dart';
import '../../general/widgets/general_coordinates_section.dart';
import '../bloc/mosque_info_bloc.dart';

class MosqueInfoSectionBody extends StatefulWidget {
  const MosqueInfoSectionBody({super.key});

  @override
  State<MosqueInfoSectionBody> createState() => _MosqueInfoSectionBodyState();
}

class _MosqueInfoSectionBodyState extends State<MosqueInfoSectionBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  bool _locating = false;
  bool _controllersInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _syncControllers(MosqueInfoState state) {
    final mosque = state.mosque?.mosque;
    if (mosque != null &&
        (!_controllersInitialized || !state.hasUnsavedChanges)) {
      final divisionLabel = mosque.administrativeDivisionName ?? mosque.city;
      if (_nameController.text != mosque.name) {
        _nameController.text = mosque.name;
      }
      if (_searchController.text != divisionLabel) {
        _searchController.text = divisionLabel;
      }
      _controllersInitialized = true;
    }
  }

  Future<void> _useCurrentLocation() async {
    final s = S.of(context);
    final bloc = context.read<MosqueInfoBloc>();
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
        MosqueInfoCoordinatesChanged(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
      UnifiedSnackbar.success(context, message: s.location_updated);
    } catch (_) {
      if (!mounted) return;
      UnifiedSnackbar.error(context, message: s.location_unavailable);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      context.read<MosqueInfoBloc>().add(const SaveMosqueInfoRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<MosqueInfoBloc, MosqueInfoState>(
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
      child: BlocBuilder<MosqueInfoBloc, MosqueInfoState>(
        builder: (context, state) {
          final mosque = state.mosque;
          if (mosque == null) {
            return const Center(child: CircularProgressIndicator());
          }
          _syncControllers(state);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  s.mosque_info_title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.mosque_info_subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: s.mosque_name_label),
                  validator: (value) =>
                      value!.trim().isEmpty ? s.required_field : null,
                  onChanged: (value) => context.read<MosqueInfoBloc>().add(
                    MosqueInfoNameChanged(value),
                  ),
                ),
                const SizedBox(height: 16),
                _DivisionSearchField(
                  controller: _searchController,
                  state: state,
                ),
                const SizedBox(height: 12),
                _DivisionPathView(
                  path: mosque.mosque.administrativeDivisionPath,
                  fallback: mosque.mosque.city,
                ),
                const SizedBox(height: 18),
                GeneralCoordinatesSection(
                  latitude: mosque.mosque.latitudeValue,
                  longitude: mosque.mosque.longitudeValue,
                  locating: _locating,
                  onUseCurrentLocation: _useCurrentLocation,
                ),
                const SizedBox(height: 32),
                AppButton.elevated(
                  label: s.save_mosque_info,
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

class _DivisionSearchField extends StatelessWidget {
  const _DivisionSearchField({required this.controller, required this.state});

  final TextEditingController controller;
  final MosqueInfoState state;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final bloc = context.read<MosqueInfoBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: s.administrative_division_label,
            hintText: s.administrative_division_search_hint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: state.isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          validator: (_) {
            final mosque = state.mosque?.mosque;
            return mosque?.administrativeDivisionId == null
                ? s.required_field
                : null;
          },
          onChanged: (value) => bloc.add(MosqueInfoSearchChanged(value)),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: state.searchResults.length,
              separatorBuilder: (_, index) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final division = state.searchResults[index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryWhisper,
                    child: Text(
                      _divisionLevelBadge(division.adminLevel),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  title: Text(
                    division.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _divisionDescription(division),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    controller.text = division.displayName;
                    bloc.add(MosqueInfoDivisionSelected(division));
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String _divisionDescription(AdministrativeDivision division) {
    final path = division.path.isNotEmpty ? division.path : [division];
    final label = path.map((item) => item.displayName).join(' / ');
    if (label.trim().isNotEmpty) return label;
    return '${division.sourceCode} - L${division.adminLevel}';
  }
}

class _DivisionPathView extends StatelessWidget {
  const _DivisionPathView({required this.path, required this.fallback});

  final List<AdministrativeDivision> path;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryWhisper.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: path.isEmpty
            ? Text(
                fallback.isEmpty ? s.administrative_division_empty : fallback,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: path
                    .map(
                      (division) => Chip(
                        label: Text(division.displayName),
                        avatar: Text(
                          _divisionLevelBadge(division.adminLevel),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}

String _divisionLevelBadge(int level) {
  return switch (level) {
    0 => 'CTR',
    1 => 'GOV',
    2 => 'DIS',
    3 => 'SUB',
    4 => 'COM',
    5 => 'ARE',
    6 => 'NBH',
    _ => 'L$level',
  };
}
