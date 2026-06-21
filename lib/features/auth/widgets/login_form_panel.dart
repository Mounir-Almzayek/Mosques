import 'package:flutter/material.dart';

import '../../../core/styles/app_colors.dart';

class LoginFormPanel extends StatelessWidget {
  const LoginFormPanel({super.key, required this.formCard});

  final Widget formCard;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.loginBackgroundGradient,
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: formCard,
            ),
          ),
        ),
      ),
    );
  }
}
