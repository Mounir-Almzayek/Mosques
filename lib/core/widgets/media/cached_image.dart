import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Thin wrapper around [CachedNetworkImage] with consistent app styling.
///
/// Provides disk + memory caching, offline support, and standardized
/// placeholder / error widgets across the app.
///
/// Usage:
/// ```dart
/// CachedImage(url: 'https://...', width: 100, height: 100)
/// CachedImage.background(url: 'https://...')
/// CachedImage.thumbnail(url: 'https://...', size: 56)
/// ```
class CachedImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final Duration fadeInDuration;

  const CachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  /// Full-screen background variant — expands to fill parent.
  const CachedImage.background({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 500),
  })  : width = double.infinity,
        height = double.infinity,
        borderRadius = null;

  /// Small thumbnail variant — fixed square size, rounded corners.
  const CachedImage.thumbnail({
    super.key,
    required this.url,
    double size = 56,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.fadeInDuration = const Duration(milliseconds: 200),
  })  : width = size,
        height = size;

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      placeholder: (context, url) =>
          placeholder ?? _defaultPlaceholder(),
      errorWidget: (context, url, error) =>
          errorWidget ?? _defaultError(),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE8EDED),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF384C4B),
          ),
        ),
      ),
    );
  }

  Widget _defaultError() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE8EDED),
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Color(0xFFA8BFBE),
          size: 28,
        ),
      ),
    );
  }
}
