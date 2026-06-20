import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/widgets/media/media_widgets.dart';
import '../../../../core/enums/display_background_type.dart';
import '../../../../core/utils/color_parser.dart';
import '../../../../data/models/mosque/display_settings.dart';

/// Duration between album background image transitions.
const Duration _kAlbumCycleDuration = Duration(seconds: 30);

/// Duration of the crossfade animation between album images.
const Duration _kAlbumCrossfadeDuration = Duration(milliseconds: 1200);

class DisplayBackgroundImage extends StatefulWidget {
  final Color fallbackColor;
  final DisplaySettings settings;
  final List<String> albumUrls;

  const DisplayBackgroundImage({
    super.key,
    required this.fallbackColor,
    required this.settings,
    this.albumUrls = const [],
  });

  @override
  State<DisplayBackgroundImage> createState() =>
      _DisplayBackgroundImageState();
}

class _DisplayBackgroundImageState extends State<DisplayBackgroundImage> {
  Timer? _albumTimer;
  int _albumIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAlbumTimerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant DisplayBackgroundImage old) {
    super.didUpdateWidget(old);
    if (old.settings.backgroundTypeKind != widget.settings.backgroundTypeKind ||
        old.albumUrls.length != widget.albumUrls.length) {
      _albumIndex = 0;
      _startAlbumTimerIfNeeded();
    }
  }

  @override
  void dispose() {
    _albumTimer?.cancel();
    super.dispose();
  }

  void _startAlbumTimerIfNeeded() {
    _albumTimer?.cancel();
    _albumTimer = null;

    if (widget.settings.backgroundTypeKind == DisplayBackgroundType.album &&
        widget.albumUrls.length > 1) {
      _albumTimer = Timer.periodic(_kAlbumCycleDuration, (_) {
        if (!mounted) return;
        setState(() {
          _albumIndex = (_albumIndex + 1) % widget.albumUrls.length;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.settings.backgroundTypeKind == DisplayBackgroundType.color) {
      final color = parseColorHex(widget.settings.backgroundValue, widget.fallbackColor);
      return Container(color: color);
    }

    if (widget.settings.backgroundTypeKind == DisplayBackgroundType.album) {
      return _buildAlbumBackground();
    }

    // Image type — remote URL stored in background_value
    final url = widget.settings.backgroundValue;

    // If value looks like a URL, load from network with caching.
    // Otherwise (empty, 'default', or old preset ID), show fallback color.
    if (url.startsWith('http')) {
      return _buildCachedImage(url);
    }

    return Container(color: widget.fallbackColor);
  }

  Widget _buildCachedImage(String url) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: widget.fallbackColor),
          child: const SizedBox.expand(),
        ),
        AppImage.networkBackground(
          url,
          placeholder: const SizedBox.shrink(),
          errorWidget: DecoratedBox(
            decoration: BoxDecoration(color: widget.fallbackColor),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumBackground() {
    final urls = widget.albumUrls;

    // If no album URLs, fall back to settings.value (legacy single URL)
    // or the fallback color.
    if (urls.isEmpty) {
      final singleUrl = widget.settings.backgroundValue;
      if (singleUrl.isNotEmpty && singleUrl.startsWith('http')) {
        return _buildCachedImage(singleUrl);
      }
      return Container(color: widget.fallbackColor);
    }

    final safeIndex = _albumIndex.clamp(0, urls.length - 1);
    final currentUrl = urls[safeIndex];

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: widget.fallbackColor),
          child: const SizedBox.expand(),
        ),
        AnimatedSwitcher(
          duration: _kAlbumCrossfadeDuration,
          child: AppImage.networkBackground(
            currentUrl,
            key: ValueKey(currentUrl),
            placeholder: const SizedBox.shrink(),
            errorWidget: DecoratedBox(
              decoration: BoxDecoration(color: widget.fallbackColor),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}
