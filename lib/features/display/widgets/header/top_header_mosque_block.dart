import 'package:flutter/material.dart';
import '../../../../core/enums/app_numeral_format.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../../core/utils/app_font_loader.dart';

class TopHeaderMosqueBlock extends StatelessWidget {
  final String mosqueName;
  final String cityName;
  final Color textColor;
  final bool isRtl;
  final double base;
  final AppNumeralFormat numeralFormat;
  final String fontFamily;

  const TopHeaderMosqueBlock({
    super.key,
    required this.mosqueName,
    required this.cityName,
    required this.textColor,
    required this.isRtl,
    required this.base,
    required this.numeralFormat,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    final align = !isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = !isRtl ? TextAlign.end : TextAlign.start;
    final locationIcon = Icon(
      Icons.location_on_outlined,
      color: textColor.withValues(alpha: 0.78),
      size: base * 1.1,
    );
    final cityText = Flexible(
      child: Text(
        cityName.formatNumerals(numeralFormat),
        textAlign: textAlign,
        style: AppFontLoader.getStyle(
          fontFamily,
          baseStyle: TextStyle(
            fontSize: base * 0.95,
            color: textColor.withValues(alpha: 0.82),
            height: 1.3,
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          mosqueName.formatNumerals(numeralFormat),
          textAlign: textAlign,
          style: AppFontLoader.getStyle(
            fontFamily,
            baseStyle: TextStyle(
              fontSize: base * 1.35,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRtl) ...[locationIcon, SizedBox(width: base * 0.35)],
            cityText,
            if (!isRtl) ...[SizedBox(width: base * 0.35), locationIcon],
          ],
        ),
      ],
    );
  }
}
