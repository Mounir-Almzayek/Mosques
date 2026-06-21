import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/services/api_service.dart';
import '../../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../bloc/recitation_bloc.dart';
import '../data/recitation_ai_repository.dart';
import '../data/recitation_audio_streamer.dart';
import '../widgets/recitation_section_body.dart';

class RecitationSection extends StatelessWidget {
  const RecitationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecitationBloc(
        repository: RecitationAiRepository(api: sl<ApiService>()),
        streamer: RecitationAudioStreamer(),
        mosqueRepository: sl<IMosqueRepository>(),
        authRepository: sl<IAuthRepository>(),
      ),
      child: const RecitationSectionBody(),
    );
  }
}
