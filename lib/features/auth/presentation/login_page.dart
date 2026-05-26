import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../bloc/login/login_bloc.dart';
import 'login_screen.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LoginBloc(authRepository: sl<IAuthRepository>()),
        ),
      ],
      child: const LoginScreen(),
    );
  }
}
