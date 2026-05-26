import 'package:flutter/material.dart';

/// Fullscreen photo display overlay (priority 2).
///
/// Loads a single network image from [imageUrl] and fills the screen.
/// Shows a progress indicator while loading and a broken-image icon on error.
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
        child: Image.network(
          imageUrl,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: _loadingBuilder,
          errorBuilder: _errorBuilder,
        ),
      ),
    );
  }

  Widget _loadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) return child;

    final expectedBytes = loadingProgress.expectedTotalBytes;
    final progress = expectedBytes != null
        ? loadingProgress.cumulativeBytesLoaded / expectedBytes
        : null;

    return Center(
      child: CircularProgressIndicator(
        value: progress,
        color: Colors.white70,
      ),
    );
  }

  Widget _errorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return const Center(
      child: Icon(
        Icons.broken_image_rounded,
        size: 80,
        color: Colors.white38,
      ),
    );
  }
}
