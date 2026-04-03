import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../../core/enums/app_numeral_format.dart';
import '../../../../../core/utils/app_number_format.dart';
import '../../../../../core/utils/app_font_loader.dart';
import '../../../../../data/models/display/ticker_segment.dart';

class TickerItemWidget extends StatelessWidget {
  final TickerSegment item;
  final double fontSize;
  final double qrSize;
  final String fontFamily;
  final AppNumeralFormat numeralFormat;
  final Color textColor;

  const TickerItemWidget({
    super.key,
    required this.item,
    required this.fontSize,
    required this.qrSize,
    required this.fontFamily,
    required this.numeralFormat,
    this.textColor = const Color(0xFFFFF8F0),
  });

  bool get _hasQr => (item.qrData ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          ' ${item.text.formatNumerals(numeralFormat)}',
          style: AppFontLoader.getStyle(
            fontFamily,
            baseStyle: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
              height: 1.34,
            ),
          ),
        ),
        if (_hasQr) ...[
          const SizedBox(width: 12),
          Container(
            width: qrSize,
            height: qrSize,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: QrImageView(
              data: item.qrData!.trim(),
              version: QrVersions.auto,
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Text(
          '      ۞      ',
          style: AppFontLoader.getStyle(
            fontFamily,
            baseStyle: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
              height: 1.34,
            ),
          ),
        ),
        const SizedBox(width: 26.0), // itemGap
      ],
    );
  }
}

