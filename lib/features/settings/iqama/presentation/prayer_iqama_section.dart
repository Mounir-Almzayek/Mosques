import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../core/refresh/settings_refresh_scope.dart';
import '../../design/bloc/design_bloc.dart';
import '../../general/bloc/general_bloc.dart';
import '../bloc/iqama_bloc.dart';
import '../widgets/prayer_iqama_section_body.dart';

class PrayerIqamaSection extends StatelessWidget {
  const PrayerIqamaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GeneralBloc>(
          create: (_) =>
              GeneralBloc(mosqueRepository: sl<IMosqueRepository>())
                ..add(const LoadGeneral()),
        ),
        BlocProvider<IqamaBloc>(
          create: (_) =>
              IqamaBloc(mosqueRepository: sl<IMosqueRepository>())
                ..add(const LoadIqama()),
        ),
        BlocProvider<DesignBloc>(
          create: (_) =>
              DesignBloc(mosqueRepository: sl<IMosqueRepository>())
                ..add(const LoadDesign()),
        ),
      ],
      child: SettingsRefreshRegistrar<GeneralBloc, GeneralState>(
        id: 'prayer_general',
        label: 'إعدادات الأذان',
        hasUnsavedChanges: (state) => state.hasUnsavedChanges,
        isSaving: (state) => state.isSaving,
        error: (state) => state.error,
        save: (bloc) => bloc.add(const SaveGeneralRequested()),
        discard: (bloc) => bloc.add(const DiscardGeneralChangesRequested()),
        child: SettingsRefreshRegistrar<IqamaBloc, IqamaState>(
          id: 'prayer_iqama',
          label: 'إعدادات الإقامة',
          hasUnsavedChanges: (state) => state.hasUnsavedChanges,
          isSaving: (state) => state.isSaving,
          error: (state) => state.error,
          save: (bloc) => bloc.add(const SaveIqamaRequested()),
          discard: (bloc) => bloc.add(const DiscardIqamaChangesRequested()),
          child: SettingsRefreshRegistrar<DesignBloc, DesignState>(
            id: 'prayer_display',
            label: 'سلوك شاشة الصلاة',
            hasUnsavedChanges: (state) => state.hasUnsavedChanges,
            isSaving: (state) => state.isSaving,
            error: (state) => state.error,
            save: (bloc) => bloc.add(const SaveDesignRequested()),
            discard: (bloc) => bloc.add(const DiscardDesignChangesRequested()),
            child: const PrayerIqamaSectionBody(),
          ),
        ),
      ),
    );
  }
}
