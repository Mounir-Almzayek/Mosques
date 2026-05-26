import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../data/repositories/interfaces/auth_repository_interface.dart';
import 'registration_bloc.dart';
import '../../presentation/registration_screen.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegistrationBloc(authRepository: sl<IAuthRepository>()),
      child: const RegistrationScreen(),
    );
  }
}
