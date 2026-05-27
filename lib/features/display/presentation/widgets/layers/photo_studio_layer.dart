import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Fullscreen photo display overlay (priority 2).
///
/// Loads a single network image from [imageUrl] with disk caching
/// for offline support. Fills the screen with optional progress indicator.
class PhotoStudioLayer extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Color backgroundColor;

  const PhotoStudioLayer({
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
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          fadeInDuration: const Duration(milliseconds: 300),
          progressIndicatorBuilder: (context, url, progress) {
            return Center(
              child: CircularProgressIndicator(
                value: progress.progress,
                color: Colors.white70,
              ),
            );
          },
          errorWidget: (context, url, error) {
            return const Center(
              child: Icon(
                Icons.broken_image_rounded,
                size: 80,
                color: Colors.white38,
              ),
            );
          },
        ),
      ),
    );
  }
}
