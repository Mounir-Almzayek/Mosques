import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';

class GeneralCoordinatesSection extends StatelessWidget {
  final double latitude;
  final double longitude;
  final bool locating;
  final VoidCallback onUseCurrentLocation;

  const GeneralCoordinatesSection({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locating,
    required this.onUseCurrentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.latitude_coordinate(latitude.toStringAsFixed(6)),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                s.longitude_coordinate(longitude.toStringAsFixed(6)),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.tonalIcon(
          onPressed: locating ? null : onUseCurrentLocation,
          icon: locating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location, size: 20),
          label: Text(s.use_current_location),
        ),
      ],
    );
  }
}
