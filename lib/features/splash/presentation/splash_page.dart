import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/splash_routing/splash_routing_bloc.dart';
import 'splash_screen.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashRoutingBloc()..add(SplashCheckStatus()),
      child: const SplashScreen(),
    );
  }
}

