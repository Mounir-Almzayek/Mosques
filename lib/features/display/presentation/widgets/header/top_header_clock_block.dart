import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../../core/enums/app_numeral_format.dart';
import '../../../../../core/utils/app_number_format.dart';
import '../../../../../core/utils/app_time_format.dart';
import '../../../../../core/utils/app_font_loader.dart';

/// Always LTR so hours/minutes/seconds never reorder under RTL layout.
class TopHeaderClockBlock extends StatelessWidget {
  final DateTime now;
  final Color textColor;
  final double base;
  final AppNumeralFormat numeralFormat;
  final String fontFamily;

  const TopHeaderClockBlock({
    super.key,
    required this.now,
    required this.textColor,
    required this.base,
    required this.numeralFormat,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    final clock = AppTimeFormat.clockParts12h(context, now);
    final hourMinute = clock.hourMinute.formatNumerals(numeralFormat);
    final seconds = clock.seconds.formatNumerals(numeralFormat);
    final period = ' ${clock.period}'.formatNumerals(numeralFormat);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                period,
                style: AppFontLoader.getStyle(
                  fontFamily,
                  baseStyle: TextStyle(
                    color: textColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w400,
                    fontSize: base * 2.15,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 5),

              Text(
                hourMinute,
                style: AppFontLoader.getStyle(
                  fontFamily,
                  baseStyle: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: base * 4.85,
                    height: 1.0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Text(
                seconds,
                style: AppFontLoader.getStyle(
                  fontFamily,
                  baseStyle: TextStyle(
                    color: textColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w400,
                    fontSize: base * 2.15,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
