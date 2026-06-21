import 'package:flutter/material.dart';

import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/media/logo_rectangle.dart';
import 'login_quote.dart';
import 'login_title_block.dart';

class LoginBrandPanel extends StatelessWidget {
  const LoginBrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const LogoRectangle(big: true, width: 240, height: 120),
                  const SizedBox(height: 32),
                  const LoginTitleBlock(onDark: true),
                  const SizedBox(height: 28),
                  const LoginQuote(onDark: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
