import 'package:flutter/material.dart';

import '../../../../core/enums/display_background_preset.dart';
import '../../../../core/widgets/optimized_image.dart';

const String kDisplayBackgroundFallbackAsset = 'assets/logo.jpg';

class DisplayBackgroundImage extends StatelessWidget {
  final Color fallbackColor;
  final String backgroundPresetId;

  const DisplayBackgroundImage({
    super.key,
    required this.fallbackColor,
    required this.backgroundPresetId,
  });

  @override
  Widget build(BuildContext context) {
    final preset = DisplayBackgroundPreset.fromStorageId(backgroundPresetId);
    final primaryPath = preset.assetPath;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: fallbackColor),
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
                  decoration: BoxDecoration(color: fallbackColor),
                  child: const SizedBox.expand(),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
