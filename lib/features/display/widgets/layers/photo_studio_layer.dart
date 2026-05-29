import 'package:flutter/material.dart';
import '../../../../core/widgets/media/media_widgets.dart';

/// Fullscreen album image display overlay (priority 2).
///
/// Loads a single network image from [imageUrl] with disk caching
/// for offline support. Fills the screen with optional progress indicator.
class AlbumImageLayer extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Color backgroundColor;

  const AlbumImageLayer({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.contain,
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: AppImage.networkBackground(
          imageUrl,
          fit: fit,
          placeholder: const Center(
            child: CircularProgressIndicator(color: Colors.white70),
          ),
          errorWidget: const Center(
            child: Icon(
              Icons.broken_image_rounded,
              size: 80,
              color: Colors.white38,
            ),
          ),
        ),
      ),
    );
  }
}
