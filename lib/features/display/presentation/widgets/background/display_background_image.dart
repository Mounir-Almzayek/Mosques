import 'package:flutter/material.dart';
import '../../../../../core/enums/display_background_preset.dart';
import '../../../../../core/enums/display_background_type.dart';
import '../../../../../core/utils/color_parser.dart';
import '../../../../../core/widgets/media/optimized_image.dart';
import '../../../../../data/models/design_background_settings.dart';

const String kDisplayBackgroundFallbackAsset = 'assets/logo.jpg';

class DisplayBackgroundImage extends StatelessWidget {
  final Color fallbackColor;
  final DesignBackgroundSettings settings;

  const DisplayBackgroundImage({
    super.key,
    required this.fallbackColor,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    if (settings.type == DisplayBackgroundType.color) {
      final color = parseColorHex(settings.value, fallbackColor);
      return Container(color: color);
    }

    final preset = DisplayBackgroundPreset.fromStorageId(settings.value);
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
