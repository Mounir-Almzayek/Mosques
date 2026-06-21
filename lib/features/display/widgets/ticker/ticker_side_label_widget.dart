import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/utils/app_font_loader.dart';

class TickerSideLabelWidget extends StatelessWidget {
  final String fontFamily;
  final double fontSize;
  final Color textColor;

  const TickerSideLabelWidget({
    super.key,
    required this.fontFamily,
    required this.fontSize,
    this.textColor = const Color(0xFFFFF8F0),
  });

  String _sideLabel(BuildContext context) {
    return S.of(context).display_ticker_ads_label;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _sideLabel(context),
            textAlign: TextAlign.center,
            maxLines: 1,
            style: AppFontLoader.getStyle(
              fontFamily,
              baseStyle: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: fontSize,
                height: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
