import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../core/widgets/forms/custom_text_field.dart';
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

  Future<void> _showAddUrlDialog(BuildContext context) async {
    final bloc = context.read<AlbumBloc>();
    final s = S.of(context);
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.album_add_url),
        content: CustomTextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          hintText: 'https://example.com/image.jpg',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                bloc.add(AlbumImageAdded(url));
                bloc.add(const SaveAlbumRequested());
              }
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A3C34),
              foregroundColor: Colors.white,
            ),
            child: Text(s.add_label),
          ),
        ],
      ),
    );

    controller.dispose();
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
          (curr.error != null && prev.error == null),
      listener: (context, state) {
        if (state.isSaving) {
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

          return Scaffold(
            body: urls.isEmpty
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
            floatingActionButton: FloatingActionButton.extended(
              heroTag: 'settings_album_fab',
              onPressed: () => _showAddUrlDialog(context),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(s.album_add_url),
              backgroundColor: const Color(0xFF1A3C34),
              foregroundColor: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
