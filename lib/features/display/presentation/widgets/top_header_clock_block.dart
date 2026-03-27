import 'package:flutter/material.dart';

import '../../../../core/enums/app_numeral_format.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../../core/utils/app_time_format.dart';

/// Always LTR so hours/minutes/seconds never reorder under RTL layout.
class TopHeaderClockBlock extends StatelessWidget {
  final DateTime now;
  final Color textColor;
  final double base;
  final AppNumeralFormat numeralFormat;

  const TopHeaderClockBlock({
    super.key,
    required this.now,
    required this.textColor,
    required this.base,
    required this.numeralFormat,
  });

  @override
  Widget build(BuildContext context) {
    final clock = AppTimeFormat.clockParts12h(context, now);
    final hourMinute = clock.hourMinute.formatNumerals(numeralFormat);
    final secondsAndPeriod = clock.secondsAndPeriod.formatNumerals(numeralFormat);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: hourMinute,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: base * 4.85,
                    height: 1.0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                TextSpan(
                  text: secondsAndPeriod,
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
