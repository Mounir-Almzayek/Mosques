import 'package:flutter/material.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';

class LoginTitleBlock extends StatelessWidget {
  const LoginTitleBlock({super.key, required this.onDark});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final titleColor = onDark ? Colors.white : AppColors.primaryText;
    final subColor = onDark
        ? Colors.white.withValues(alpha: 0.82)
        : AppColors.secondaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          s.login_title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.responsive(24, tablet: 26, desktop: 30),
            fontWeight: FontWeight.bold,
            color: titleColor,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s.login_subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.responsive(14, tablet: 15, desktop: 16),
            color: subColor,
          ),
        ),
      ],
    );
  }
}
