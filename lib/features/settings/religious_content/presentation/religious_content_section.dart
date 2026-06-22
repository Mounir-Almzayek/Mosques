import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../core/refresh/settings_refresh_scope.dart';
import '../bloc/religious_content_bloc.dart';
import '../widgets/religious_content_section_body.dart';

class ReligiousContentSection extends StatelessWidget {
  const ReligiousContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReligiousContentBloc>(
      create: (_) =>
          ReligiousContentBloc(mosqueRepository: sl<IMosqueRepository>())
            ..add(const LoadReligiousContent()),
      child:
          SettingsRefreshRegistrar<ReligiousContentBloc, ReligiousContentState>(
            id: 'religious_content',
            label: 'المحتوى الديني',
            hasUnsavedChanges: (state) => state.hasUnsavedChanges,
            isSaving: (state) => state.isSaving,
            error: (state) => state.error,
            save: (bloc) => bloc.add(const SaveAllReligiousContentRequested()),
            discard: (bloc) =>
                bloc.add(const DiscardReligiousContentChangesRequested()),
            child: const ReligiousContentSectionBody(),
          ),
    );
  }
}
