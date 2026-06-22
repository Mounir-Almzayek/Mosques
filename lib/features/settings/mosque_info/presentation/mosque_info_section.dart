import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../data/repositories/interfaces/administrative_divisions_repository_interface.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../core/refresh/settings_refresh_scope.dart';
import '../bloc/mosque_info_bloc.dart';
import '../widgets/mosque_info_section_body.dart';

class MosqueInfoSection extends StatelessWidget {
  const MosqueInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MosqueInfoBloc>(
      create: (_) => MosqueInfoBloc(
        mosqueRepository: sl<IMosqueRepository>(),
        divisionsRepository: sl<IAdministrativeDivisionsRepository>(),
      )..add(const LoadMosqueInfo()),
      child: SettingsRefreshRegistrar<MosqueInfoBloc, MosqueInfoState>(
        id: 'mosque_info',
        label: 'معلومات المسجد',
        hasUnsavedChanges: (state) => state.hasUnsavedChanges,
        isSaving: (state) => state.isSaving,
        error: (state) => state.error,
        save: (bloc) => bloc.add(const SaveMosqueInfoRequested()),
        discard: (bloc) => bloc.add(const DiscardMosqueInfoChangesRequested()),
        child: const MosqueInfoSectionBody(),
      ),
    );
  }
}
