import 'package:flutter/material.dart';

/// A set of utilities to handle high-resolution assets efficiently in Flutter.
/// By using cacheWidth/cacheHeight, we decode images into smaller memory buffers,
/// significantly reducing RAM usage and preventing frame drops.
class OptimizedImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? cacheWidth;
  final int? cacheHeight;
  final Widget? placeholder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final bool gaplessPlayback;

  const OptimizedImage.asset(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.cacheHeight,
    this.placeholder,
    this.errorBuilder,
    this.gaplessPlayback = true,
  });

  /// Factory for thumbnails (e.g., in grids).
  /// Decodes image to a small fixed size regardless of asset resolution.
  factory OptimizedImage.thumbnail(
    String assetPath, {
    Key? key,
    int size = 300,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    return OptimizedImage.asset(
      assetPath,
      key: key,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: size,
      errorBuilder: errorBuilder,
    );
  }

  /// Factory for full-screen backgrounds.
  /// Decodes image to the screen's physical width (capped for performance).
  factory OptimizedImage.background(
    String assetPath, {
    Key? key,
    required BuildContext context,
    BoxFit fit = BoxFit.cover,
    int maxDimension = 1920,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    final media = MediaQuery.of(context);
    final physicalWidth = (media.size.width * media.devicePixelRatio).round();
    final cappedWidth = physicalWidth > maxDimension ? maxDimension : physicalWidth;

    return OptimizedImage.asset(
      assetPath,
      key: key,
      fit: fit,
      cacheWidth: cappedWidth,
      gaplessPlayback: true,
      errorBuilder: errorBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      gaplessPlayback: gaplessPlayback,
      errorBuilder: errorBuilder ?? (context, error, stack) => 
          placeholder ?? const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey)),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }
}

/// Helper to precache an image with specific optimization parameters.
Future<void> precacheOptimizedAsset(
  BuildContext context,
  String assetPath, {
  int? cacheWidth,
  int? cacheHeight,
}) {
  final ImageProvider provider = ResizeImage.resizeIfNeeded(
    cacheWidth,
    cacheHeight,
    AssetImage(assetPath),
  );
  return precacheImage(provider, context);
}
