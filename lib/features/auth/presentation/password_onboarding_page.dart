import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../bloc/password_onboarding/password_onboarding_bloc.dart';
import 'password_onboarding_screen.dart';

class PasswordOnboardingPage extends StatelessWidget {
  const PasswordOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PasswordOnboardingBloc(authRepository: sl<IAuthRepository>()),
      child: const PasswordOnboardingScreen(),
    );
  }
}
