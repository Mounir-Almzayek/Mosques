import 'package:flutter/material.dart';
import '../../../../../core/l10n/generated/l10n.dart';
import 'design_card.dart';

class BehaviorSettingsSection extends StatelessWidget {
  final double tickerSpeed;
  final ValueChanged<double> onTickerSpeedChanged;
  final double stripSpeed;
  final ValueChanged<double> onStripSpeedChanged;

  const BehaviorSettingsSection({
    super.key,
    required this.tickerSpeed,
    required this.onTickerSpeedChanged,
    required this.stripSpeed,
    required this.onStripSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DesignSectionTitle(
            title: s.design_behavior_title,
            icon: Icons.speed_rounded,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.slow_motion_video_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      s.design_ticker_speed,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      '${tickerSpeed.toStringAsFixed(1)}x',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: tickerSpeed,
                  min: 0.2,
                  max: 3.0,
                  divisions: 28,
                  onChanged: (v) => onTickerSpeedChanged(double.parse(v.toStringAsFixed(1))),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.article_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      s.design_strip_speed,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      '${stripSpeed.toStringAsFixed(1)}x',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: stripSpeed,
                  min: 0.2,
                  max: 3.0,
                  divisions: 28,
                  onChanged: (v) => onStripSpeedChanged(double.parse(v.toStringAsFixed(1))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
