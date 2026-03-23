
import 'package:flutter/material.dart';

import '../../../../core/utils/app_time_format.dart';

/// Always LTR so hours/minutes/seconds never reorder under RTL layout.
class TopHeaderClockBlock extends StatelessWidget {
  final DateTime now;
  final Color textColor;
  final double base;

  const TopHeaderClockBlock({
    super.key,
    required this.now,
    required this.textColor,
    required this.base,
  });

  @override
  Widget build(BuildContext context) {
    final clock = AppTimeFormat.clockParts12h(context, now);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: clock.hourMinute,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: base * 4.85,
                    height: 1.0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                TextSpan(
                  text: clock.secondsAndPeriod,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w400,
                    fontSize: base * 2.15,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
