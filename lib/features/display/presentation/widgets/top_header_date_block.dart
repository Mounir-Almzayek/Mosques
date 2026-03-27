import 'package:flutter/material.dart';
import '../../../../core/utils/app_font_loader.dart';

class TopHeaderDateBlock extends StatelessWidget {
  final String weekday;
  final String gregorianLong;
  final String hijriLine;
  final Color textColor;
  final bool isRtl;
  final double base;
  final String fontFamily;

  const TopHeaderDateBlock({
    super.key,
    required this.weekday,
    required this.gregorianLong,
    required this.hijriLine,
    required this.textColor,
    required this.isRtl,
    required this.base,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    final textAlign = isRtl ? TextAlign.start : TextAlign.end;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          weekday,
          textAlign: textAlign,
          style: AppFontLoader.getStyle(
            fontFamily,
            baseStyle: TextStyle(
              fontSize: base * 1.35,
              fontWeight: FontWeight.w700,
              color: textColor.withValues(alpha: 0.92),
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          gregorianLong,
          textAlign: textAlign,
          style: AppFontLoader.getStyle(
            fontFamily,
            baseStyle: TextStyle(
              fontSize: base * 1.15,
              color: textColor.withValues(alpha: 0.78),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          hijriLine,
          textAlign: textAlign,
          style: AppFontLoader.getStyle(
            fontFamily,
            baseStyle: TextStyle(
              fontSize: base * 1.15,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }
}
