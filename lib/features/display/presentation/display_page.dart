import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/repositories/interfaces/app_config_repository_interface.dart';
import '../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../../data/repositories/interfaces/platform_announcements_repository_interface.dart';
import '../bloc/display_bloc.dart';
import 'display_screen.dart';

class DisplayPage extends StatelessWidget {
  const DisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DisplayBloc(
        mosqueRepository: sl<IMosqueRepository>(),
        platformAnnouncementsRepository: sl<IPlatformAnnouncementsRepository>(),
        appSettingsRepository: sl<IAppConfigRepository>(),
      )..add(StartDisplaySubscription()),
      child: const DisplayScreen(),
    );
  }
}
