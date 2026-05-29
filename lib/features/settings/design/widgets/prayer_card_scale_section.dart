import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import 'design_card.dart';
import 'design_section_title.dart';

class PrayerCardScaleSection extends StatelessWidget {
  final S s;
  final double value;
  final ValueChanged<double> onChanged;

  const PrayerCardScaleSection({
    super.key,
    required this.s,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(1.0, 3.0);

    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DesignSectionTitle(
            title: s.prayer_card_scale,
            icon: Icons.aspect_ratio_outlined,
          ),
          Row(
            children: [
              const Text('1.0x'),
              Expanded(
                child: Slider(
                  value: clampedValue,
                  min: 1.0,
                  max: 3.0,
                  divisions: 20,
                  label: '${value.toStringAsFixed(1)}x',
                  onChanged: onChanged,
                ),
              ),
              const Text('3.0x'),
            ],
          ),
          Center(
            child: Text(
              '${value.toStringAsFixed(1)}x',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
