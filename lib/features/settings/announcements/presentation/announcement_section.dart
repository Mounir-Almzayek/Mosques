import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../core/refresh/settings_refresh_scope.dart';
import '../bloc/announcements_bloc.dart';
import '../widgets/announcement_section_body.dart';

class AnnouncementSection extends StatelessWidget {
  const AnnouncementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnnouncementsBloc>(
      create: (_) =>
          AnnouncementsBloc(mosqueRepository: sl<IMosqueRepository>())
            ..add(const LoadAnnouncements()),
      child: SettingsRefreshRegistrar<AnnouncementsBloc, AnnouncementsState>(
        id: 'announcements',
        label: 'الإعلانات',
        hasUnsavedChanges: (state) => state.hasUnsavedChanges,
        isSaving: (state) => state.isSaving,
        error: (state) => state.error,
        save: (bloc) => bloc.add(const SaveAnnouncementsRequested()),
        discard: (bloc) =>
            bloc.add(const DiscardAnnouncementsChangesRequested()),
        child: const AnnouncementSectionBody(),
      ),
    );
  }
}
