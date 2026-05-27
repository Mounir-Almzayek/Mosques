import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../../core/enums/display_background_preset.dart';
import '../../../../../core/enums/display_background_type.dart';
import '../../../../../core/utils/color_parser.dart';
import '../../../../../core/widgets/media/optimized_image.dart';
import '../../../../../data/models/design/design_background_settings.dart';

const String kDisplayBackgroundFallbackAsset = 'assets/logo.png';

/// Duration between album background image transitions.
const Duration _kAlbumCycleDuration = Duration(seconds: 30);

/// Duration of the crossfade animation between album images.
const Duration _kAlbumCrossfadeDuration = Duration(milliseconds: 1200);

class DisplayBackgroundImage extends StatefulWidget {
  final Color fallbackColor;
  final DesignBackgroundSettings settings;
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
    if (old.settings.type != widget.settings.type ||
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

    if (widget.settings.type == DisplayBackgroundType.album &&
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
    if (widget.settings.type == DisplayBackgroundType.color) {
      final color = parseColorHex(widget.settings.value, widget.fallbackColor);
      return Container(color: color);
    }

    if (widget.settings.type == DisplayBackgroundType.album) {
      return _buildAlbumBackground();
    }

    // Image preset background
    final preset =
        DisplayBackgroundPreset.fromStorageId(widget.settings.value);
    final primaryPath = preset.assetPath;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: widget.fallbackColor),
          child: const SizedBox.expand(),
        ),
        OptimizedImage.background(
          primaryPath,
          context: context,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return OptimizedImage.background(
              kDisplayBackgroundFallbackAsset,
              context: context,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return DecoratedBox(
                  decoration: BoxDecoration(color: widget.fallbackColor),
                  child: const SizedBox.expand(),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAlbumBackground() {
    final urls = widget.albumUrls;

    // If no album URLs, fall back to settings.value (legacy single URL)
    // or the fallback color.
    if (urls.isEmpty) {
      final singleUrl = widget.settings.value;
      if (singleUrl.isNotEmpty) {
        return _buildNetworkImage(singleUrl);
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
          child: Image.network(
            currentUrl,
            key: ValueKey(currentUrl),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return DecoratedBox(
                decoration: BoxDecoration(color: widget.fallbackColor),
                child: const SizedBox.expand(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkImage(String url) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: widget.fallbackColor),
          child: const SizedBox.expand(),
        ),
        Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return DecoratedBox(
              decoration: BoxDecoration(color: widget.fallbackColor),
              child: const SizedBox.expand(),
            );
          },
        ),
      ],
    );
  }
}
