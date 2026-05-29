import 'package:flutter/material.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/forms/custom_text_field.dart';
import 'album_url_add_card.dart';
import 'album_url_empty_state.dart';
import 'album_url_image_card.dart';

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

  Future<void> _showAddDialog(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).photo_studio_add_url),
        content: CustomTextField(
          controller: controller,
          hintText: 'https://example.com/image.jpg',
          label: S.of(context).url_label,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
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
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return AlbumUrlEmptyState(onAddPressed: () => _showAddDialog(context));
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
              return AlbumUrlAddCard(onTap: () => _showAddDialog(context));
            }
            return AlbumUrlImageCard(
              url: urls[index],
              onRemove: () => onUrlRemoved(index),
            );
          },
        ),
      ],
    );
  }
}
