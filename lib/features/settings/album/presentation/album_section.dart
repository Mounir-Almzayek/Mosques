import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../core/widgets/media/media_widgets.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../bloc/album_bloc.dart';

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
      child: const _AlbumSectionBody(),
    );
  }
}

class _AlbumSectionBody extends StatelessWidget {
  const _AlbumSectionBody();

  // ── Published detection ─────────────────────────────────────────────────

  static bool _isImageLive(MosqueModel mosque, String url) {
    if (mosque.publishedAlbumImageUrl != url) return false;
    if (mosque.publishedAlbumImageAt == null) return false;
    final expiry = mosque.publishedAlbumImageAt!.add(
      Duration(seconds: mosque.publishedAlbumImageDuration),
    );
    return DateTime.now().isBefore(expiry);
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  Future<void> _showAddUrlDialog(BuildContext context) async {
    final bloc = context.read<AlbumBloc>();
    final s = S.of(context);
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.album_add_url),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
          ),
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

  void _showPublishSheet(BuildContext context, String url, bool isLive) {
    final bloc = context.read<AlbumBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => _PublishBottomSheet(
        url: url,
        isLive: isLive,
        onPublish: (durationSeconds) {
          bloc.add(AlbumImagePublished(url, durationSeconds));
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

  // ── Build ────────────────────────────────────────────────────────────────

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
          final urls = mosque.albumImageUrls;

          return Scaffold(
            body: urls.isEmpty
                ? _EmptyState(s: s)
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
                      return _GridCell(
                        url: url,
                        isLive: live,
                        liveBadgeLabel: s.album_live_badge,
                        onTap: () => _showPublishSheet(context, url, live),
                      );
                    },
                  ),
            floatingActionButton: FloatingActionButton.extended(
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

// ── Grid cell ────────────────────────────────────────────────────────────────

class _GridCell extends StatelessWidget {
  final String url;
  final bool isLive;
  final String liveBadgeLabel;
  final VoidCallback onTap;

  const _GridCell({
    required this.url,
    required this.isLive,
    required this.liveBadgeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail
            CachedImage(
              url: url,
              fit: BoxFit.cover,
            ),

            // Subtle dark overlay so the badge is legible on bright images
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),

            // LIVE badge
            if (isLive)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    liveBadgeLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

            // Tap hint icon (bottom-right)
            Positioned(
              right: 6,
              bottom: 6,
              child: Icon(
                Icons.open_in_full_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final S s;
  const _EmptyState({required this.s});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              s.album_empty,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Publish bottom sheet ─────────────────────────────────────────────────────

class _PublishBottomSheet extends StatefulWidget {
  final String url;
  final bool isLive;
  final void Function(int durationSeconds) onPublish;
  final VoidCallback onUnpublish;
  final VoidCallback onDelete;

  const _PublishBottomSheet({
    required this.url,
    required this.isLive,
    required this.onPublish,
    required this.onUnpublish,
    required this.onDelete,
  });

  @override
  State<_PublishBottomSheet> createState() => _PublishBottomSheetState();
}

class _PublishBottomSheetState extends State<_PublishBottomSheet> {
  int _durationSeconds = 60;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        left: 24,
        right: 24,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Preview thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 160,
              child: CachedImage(
                url: widget.url,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Duration slider
          Row(
            children: [
              Text(
                s.album_publish_duration,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '$_durationSeconds ${s.album_seconds_suffix}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Slider(
            value: _durationSeconds.toDouble(),
            min: 10,
            max: 300,
            divisions: 29,
            activeColor: const Color(0xFF1A3C34),
            onChanged: (v) => setState(() => _durationSeconds = v.toInt()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10 ${s.album_seconds_suffix}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              Text(
                '300 ${s.album_seconds_suffix}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Publish / Unpublish button
          FilledButton.icon(
            onPressed: () => widget.onPublish(_durationSeconds),
            icon: const Icon(Icons.play_circle_outline),
            label: Text(s.album_publish),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A3C34),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          if (widget.isLive) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: widget.onUnpublish,
              icon: const Icon(Icons.stop_circle_outlined),
              label: Text(s.album_unpublish),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade700,
                side: BorderSide(color: Colors.orange.shade700),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Delete button
          OutlinedButton.icon(
            onPressed: widget.onDelete,
            icon: const Icon(Icons.delete_outline),
            label: Text(s.delete),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
