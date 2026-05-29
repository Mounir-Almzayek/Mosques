import 'package:flutter/material.dart';

import '../../cache/offline_image_store.dart';
import '../../di/service_locator.dart';
import 'app_network_image.dart';
import 'optimized_image.dart';

/// The single entry point for displaying images across the app.
///
/// - `AppImage.network(url)` resolves: permanent offline file → network
///   (cached) → placeholder/error. When loaded over network, the image is
///   persisted to the offline store for the next launch.
/// - `AppImage.asset(path)` delegates to [OptimizedImage] for size-aware decode.
class AppImage extends StatelessWidget {
  final _AppImageKind _kind;
  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Duration fadeInDuration;
  final Widget? placeholder;
  final Widget? errorWidget;
  final OfflineImageStore? _imageStoreOverride;

  static const Color _bg = Color(0xFFE8EDED);
  static const Color _fg = Color(0xFFA8BFBE);

  const AppImage._({
    super.key,
    required _AppImageKind kind,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholder,
    this.errorWidget,
    OfflineImageStore? imageStore,
  })  : _kind = kind,
        _imageStoreOverride = imageStore;

  factory AppImage.network(
    String url, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Duration fadeInDuration = const Duration(milliseconds: 300),
    Widget? placeholder,
    Widget? errorWidget,
    OfflineImageStore? imageStore,
  }) =>
      AppImage._(
        key: key,
        kind: _AppImageKind.network,
        source: url,
        width: width,
        height: height,
        fit: fit,
        borderRadius: borderRadius,
        fadeInDuration: fadeInDuration,
        placeholder: placeholder,
        errorWidget: errorWidget,
        imageStore: imageStore,
      );

  factory AppImage.networkBackground(
    String url, {
    Key? key,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    OfflineImageStore? imageStore,
  }) =>
      AppImage._(
        key: key,
        kind: _AppImageKind.network,
        source: url,
        width: double.infinity,
        height: double.infinity,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 500),
        placeholder: placeholder,
        errorWidget: errorWidget,
        imageStore: imageStore,
      );

  factory AppImage.networkThumbnail(
    String url, {
    Key? key,
    double size = 56,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    OfflineImageStore? imageStore,
  }) =>
      AppImage._(
        key: key,
        kind: _AppImageKind.network,
        source: url,
        width: size,
        height: size,
        fit: fit,
        borderRadius: borderRadius,
        fadeInDuration: const Duration(milliseconds: 200),
        imageStore: imageStore,
      );

  const AppImage.asset(
    String path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  })  : _kind = _AppImageKind.asset,
        source = path,
        borderRadius = null,
        fadeInDuration = const Duration(milliseconds: 300),
        placeholder = null,
        errorWidget = null,
        _imageStoreOverride = null;

  OfflineImageStore get _store =>
      _imageStoreOverride ?? sl<OfflineImageStore>();

  @override
  Widget build(BuildContext context) {
    if (_kind == _AppImageKind.asset) {
      return OptimizedImage.asset(
        source,
        width: width,
        height: height,
        fit: fit,
      );
    }
    return AppNetworkImage(
      source: source,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      fadeInDuration: fadeInDuration,
      placeholder: placeholder,
      errorWidget: errorWidget,
      store: _store,
      bg: _bg,
      fg: _fg,
    );
  }
}

enum _AppImageKind { network, asset }
