import 'package:flutter/material.dart';
import '../../../../../core/utils/app_font_loader.dart';

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
    final locale = Localizations.localeOf(context);
    if (locale.languageCode.toLowerCase().startsWith('ar')) {
      return 'إعلانات';
    }
    return 'Ads';
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
