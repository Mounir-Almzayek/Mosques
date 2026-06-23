import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../data/models/mosque/mosque_bootstrap.dart';
import '../bloc/album_bloc.dart';
import 'album_empty_state.dart';
import 'album_grid_cell.dart';
import 'album_publish_bottom_sheet.dart';

class AlbumSectionBody extends StatelessWidget {
  const AlbumSectionBody({super.key});

  static bool _isImageLive(MosqueBootstrap mosque, String url) {
    final ds = mosque.displaySettings;
    if (ds.publishedAlbumUrl != url) return false;
    if (ds.publishedAlbumAt == null) return false;

    final expiry = ds.publishedAlbumAt!.add(
      Duration(seconds: ds.publishedAlbumDurationSeconds ?? 30),
    );
    return DateTime.now().isBefore(expiry);
  }

  Future<void> _showImageSourceSheet(BuildContext context) async {
    final bloc = context.read<AlbumBloc>();
    final s = S.of(context);

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: Text(s.gallery),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickAndUpload(context, bloc, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded),
                title: Text(s.camera),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickAndUpload(context, bloc, ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(
    BuildContext context,
    AlbumBloc bloc,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );
    if (image == null || !context.mounted) return;
    bloc.add(AlbumImageUploadRequested(image.path));
  }

  void _showPublishSheet(
    BuildContext context,
    MosqueBootstrap mosque,
    String url,
    bool isLive,
  ) {
    final bloc = context.read<AlbumBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => AlbumPublishBottomSheet(
        url: url,
        isLive: isLive,
        initialDurationSeconds:
            mosque.displaySettings.publishedAlbumDurationSeconds ?? 30,
        initialFit: mosque.displaySettings.publishedAlbumFit,
        onPublish: (durationSeconds, fit) {
          bloc.add(AlbumImagePublished(url, durationSeconds, fit));
          bloc.add(const SaveAlbumRequested());
          Navigator.pop(sheetCtx);
        },
        onUnpublish: () {
          bloc.add(const AlbumImageUnpublished());
          bloc.add(const SaveAlbumRequested());
          Navigator.pop(sheetCtx);
        },
        onDelete: () {
          bloc.add(AlbumImageRemoved(url));
          bloc.add(const SaveAlbumRequested());
          Navigator.pop(sheetCtx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<AlbumBloc, AlbumState>(
      listenWhen: (prev, curr) =>
          prev.isSaving != curr.isSaving ||
          prev.isUploading != curr.isUploading ||
          (curr.error != null && prev.error == null),
      listener: (context, state) {
        if (state.isSaving || state.isUploading) {
          UnifiedSnackbar.info(context, message: S.of(context).saving);
        } else if (state.error != null) {
          UnifiedSnackbar.error(context, message: state.error!);
        } else {
          UnifiedSnackbar.hide(context);
          UnifiedSnackbar.success(
            context,
            message: S.of(context).saved_successfully,
          );
        }
      },
      child: BlocBuilder<AlbumBloc, AlbumState>(
        builder: (context, state) {
          final mosque = state.mosque;
          if (mosque == null) return const SizedBox.shrink();

          final urls = mosque.displaySettings.albumImageUrls;
          final isBusy = state.isSaving || state.isUploading;

          return Scaffold(
            body: Stack(
              children: [
                urls.isEmpty
                    ? AlbumEmptyState(s: s)
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: urls.length,
                        itemBuilder: (context, index) {
                          final url = urls[index];
                          final live = _isImageLive(mosque, url);
                          return AlbumGridCell(
                            url: url,
                            isLive: live,
                            liveBadgeLabel: s.album_live_badge,
                            onTap: () =>
                                _showPublishSheet(context, mosque, url, live),
                          );
                        },
                      ),
                if (state.isUploading)
                  const PositionedDirectional(
                    top: 0,
                    start: 0,
                    end: 0,
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              heroTag: 'settings_album_fab',
              onPressed: isBusy ? null : () => _showImageSourceSheet(context),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(s.upload_image),
              backgroundColor: const Color(0xFF1A3C34),
              foregroundColor: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
