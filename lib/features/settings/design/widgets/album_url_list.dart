import 'package:flutter/material.dart';
import 'album_url_empty_state.dart';
import 'album_url_image_card.dart';

/// Visual grid of album background images with add/remove capability.
///
/// Each image is displayed as a 16:10 thumbnail with a delete overlay.
class AlbumUrlList extends StatelessWidget {
  final List<String> urls;
  final void Function(int) onUrlRemoved;

  const AlbumUrlList({
    super.key,
    required this.urls,
    required this.onUrlRemoved,
  });

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return const AlbumUrlEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: urls.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 16 / 10,
          ),
          itemBuilder: (context, index) {
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
