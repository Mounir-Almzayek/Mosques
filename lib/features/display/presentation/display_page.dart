import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/display_bloc.dart';
import 'display_screen.dart';

class DisplayPage extends StatelessWidget {
  const DisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DisplayBloc()..add(StartDisplaySubscription()),
      child: const DisplayScreen(),
    );
  }
}
