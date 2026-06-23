import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../cache/offline_image_store.dart';

/// Stateful widget that handles the offline-first network image logic.
///
/// Uses [StatefulWidget] so that async store lookups happen in [initState]
/// and do not block the widget's [build] method or the test pump loop.
class AppNetworkImage extends StatefulWidget {
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

  const AppNetworkImage({
    super.key,
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
  State<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends State<AppNetworkImage> {
  File? _cachedFile;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _loadFromStore();
  }

  @override
  void didUpdateWidget(covariant AppNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source == widget.source) return;
    _cachedFile = null;
    _resolved = false;
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
