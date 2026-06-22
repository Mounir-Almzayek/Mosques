import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../core/refresh/settings_refresh_scope.dart';
import '../bloc/album_bloc.dart';
import '../widgets/album_section_body.dart';

/// Album section — grid of image thumbnails with publish-to-display flow.
///
/// Each image can be tapped to open a publish sheet where the admin
/// configures a display duration and pushes the image live.  A FAB adds
/// new images by URL; long-pressing (or the delete icon on the sheet)
/// removes them.
class AlbumSection extends StatelessWidget {
  const AlbumSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AlbumBloc>(
      create: (_) =>
          AlbumBloc(mosqueRepository: sl<IMosqueRepository>())
            ..add(const LoadAlbum()),
      child: SettingsRefreshRegistrar<AlbumBloc, AlbumState>(
        id: 'album',
        label: 'مكتبة الصور',
        hasUnsavedChanges: (state) => state.hasUnsavedChanges,
        isSaving: (state) => state.isSaving,
        error: (state) => state.error,
        save: (bloc) => bloc.add(const SaveAlbumRequested()),
        discard: (bloc) => bloc.add(const DiscardAlbumChangesRequested()),
        child: const AlbumSectionBody(),
      ),
    );
  }
}
