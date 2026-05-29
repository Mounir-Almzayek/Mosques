import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../cache/offline_image_store.dart';
import '../../di/service_locator.dart';
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
    return _AppNetworkImage(
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

/// Internal stateful widget that handles the offline-first network image logic.
/// Uses [StatefulWidget] so that async store lookups happen in [initState]
/// and do not block the widget's [build] method or the test pump loop.
class _AppNetworkImage extends StatefulWidget {
  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Duration fadeInDuration;
  final Widget? placeholder;
  final Widget? errorWidget;
  final OfflineImageStore store;
  final Color bg;
  final Color fg;

  const _AppNetworkImage({
    required this.source,
    required this.width,
    required this.height,
    required this.fit,
    required this.borderRadius,
    required this.fadeInDuration,
    required this.placeholder,
    required this.errorWidget,
    required this.store,
    required this.bg,
    required this.fg,
  });

  @override
  State<_AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends State<_AppNetworkImage> {
  File? _cachedFile;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _loadFromStore();
  }

  Future<void> _loadFromStore() async {
    try {
      final file = await widget.store.fileFor(widget.source);
      if (!mounted) return;
      if (file != null) {
        setState(() {
          _cachedFile = file;
          _resolved = true;
        });
        return;
      }
    } catch (_) {
      // fall through to network
    }
    if (!mounted) return;
    setState(() {
      _resolved = true;
    });
    // Background persist for next launch
    widget.store.fetchAndStore(widget.source).catchError((Object _) => File(''));
  }

  @override
  Widget build(BuildContext context) {
    if (!_resolved) {
      return _wrap(_buildPlaceholder());
    }
    final file = _cachedFile;
    if (file != null) {
      return _wrap(Image.file(
        file,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (_, e, s) => _buildError(),
      ));
    }
    return _wrap(CachedNetworkImage(
      imageUrl: widget.source,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      fadeInDuration: widget.fadeInDuration,
      placeholder: (_, u) => _buildPlaceholder(),
      errorWidget: (_, u, e) => _buildError(),
    ));
  }

  Widget _wrap(Widget child) {
    final br = widget.borderRadius;
    if (br == null) return child;
    return ClipRRect(borderRadius: br, child: child);
  }

  Widget _buildPlaceholder() =>
      widget.placeholder ??
      Container(
        width: widget.width,
        height: widget.height,
        color: widget.bg,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Color(0xFF384C4B)),
          ),
        ),
      );

  Widget _buildError() =>
      widget.errorWidget ??
      Container(
        width: widget.width,
        height: widget.height,
        color: widget.bg,
        child: Center(
          child: Icon(Icons.broken_image_outlined, color: widget.fg, size: 28),
        ),
      );
}

enum _AppImageKind { network, asset }
