import 'package:flutter/material.dart';

import '../../../../core/utils/app_font_loader.dart';

class AlertTextBlock extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color accent;
  final String fontFamily;
  final double alertsFontSize;
  final String badgeLabel;
  final bool center;

  const AlertTextBlock({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.fontFamily,
    required this.alertsFontSize,
    required this.badgeLabel,
    required this.center,
  });

  @override
  Widget build(BuildContext context) {
    final titleSize = (alertsFontSize * 3.2).clamp(28.0, 120.0);
    final subtitleSize = (alertsFontSize * 1.9).clamp(16.0, 72.0);
    final align = center ? TextAlign.center : TextAlign.start;
    final cross =
        center ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: cross,
      children: [
        Text(
          title,
          textAlign: align,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppFontLoader.getStyle(
            fontFamily,
            baseStyle: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w900,
              color: accent,
              height: 1.25,
            ),
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            subtitle!,
            textAlign: align,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppFontLoader.getStyle(
              fontFamily,
              baseStyle: TextStyle(
                fontSize: subtitleSize,
                fontWeight: FontWeight.w500,
                color: accent.withValues(alpha: 0.85),
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
