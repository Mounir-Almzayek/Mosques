import 'package:flutter/material.dart';
import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/widgets/media/media_widgets.dart';

/// Visual grid of album background images with add/remove capability.
///
/// Each image is displayed as a 16:10 thumbnail with a delete overlay.
/// An "add" card at the end opens a URL input dialog.
class AlbumUrlList extends StatelessWidget {
  final List<String> urls;
  final ValueChanged<String> onUrlAdded;
  final void Function(int) onUrlRemoved;

  const AlbumUrlList({
    super.key,
    required this.urls,
    required this.onUrlAdded,
    required this.onUrlRemoved,
  });

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).photo_studio_add_url),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'https://example.com/image.jpg',
            labelText: S.of(context).url_label,
          ),
          keyboardType: TextInputType.url,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) onUrlAdded(url);
              Navigator.pop(ctx);
            },
            child: Text(S.of(context).add_label),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: urls.length + 1, // +1 for the add card
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 16 / 10,
          ),
          itemBuilder: (context, index) {
            if (index == urls.length) {
              return _buildAddCard(context);
            }
            return _buildImageCard(context, index, urls[index]);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: AppColors.primarySurface,
          ),
          const SizedBox(height: 12),
          Text(
            'لا توجد صور ألبوم',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
            label: Text(S.of(context).add_label),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, int index, String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedImage(
            url: url,
            fit: BoxFit.cover,
          ),
          // Dark gradient overlay at top for delete button visibility
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 32,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Delete button
          Positioned(
            top: 2,
            right: 2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onUrlRemoved(index),
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showAddDialog(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primarySurface,
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            color: AppColors.primaryWhisper.withValues(alpha: 0.3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                S.of(context).add_label,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
