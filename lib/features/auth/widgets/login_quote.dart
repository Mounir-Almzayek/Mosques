import 'package:flutter/material.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';

class LoginQuote extends StatelessWidget {
  const LoginQuote({super.key, required this.onDark});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      S.of(context).tawakkul_quote,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: context.responsive(12, tablet: 13, desktop: 14),
        height: 1.7,
        color: onDark
            ? Colors.white.withValues(alpha: 0.78)
            : AppColors.secondaryText.withValues(alpha: 0.85),
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
