import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../data/repositories/imam_tracking_repository.dart';
import '../data/services/imam_audio_recorder.dart';
import 'bloc/recitation_bloc.dart';
import 'bloc/recitation_event.dart';
import 'bloc/recitation_state.dart';
import 'widgets/recitation_errors_panel.dart';

class RecitationPage extends StatelessWidget {
  const RecitationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImamTrackingBloc>(
      create: (_) => ImamTrackingBloc(
        repository: ImamTrackingRepository(),
        mosqueRepository: sl<IMosqueRepository>(),
        audioRecorder: ImamAudioRecorder(),
      )..add(const LoadImamTracking()),
      child: const RecitationPageBody(),
    );
  }
}

class RecitationPageBody extends StatelessWidget {
  const RecitationPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<ImamTrackingBloc, ImamTrackingState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ColoredBox(
            color: const Color(0xFFECE8DE),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton.elevated(
                    label: state.isDisplayActive
                        ? 'إنهاء تتبع قراءة الإمام'
                        : 'بدء تتبع قراءة الإمام',
                    onPressed: () {
                      context.read<ImamTrackingBloc>().add(
                        state.isDisplayActive
                            ? const StopImamDisplay()
                            : const StartImamDisplay(),
                      );
                    },
                    isLoading: state.isPublishing,
                    disabled: state.isPublishing,
                    leadingIcon: state.isDisplayActive
                        ? Icons.stop_circle_rounded
                        : Icons.mic_rounded,
                    height: 56,
                    fontSize: 16,
                    borderRadius: 16,
                    gradient: state.isDisplayActive
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFD14B4B), AppColors.error],
                          )
                        : AppColors.primaryGradient,
                  ),
                  if (state.publishError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      state.publishError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: RecitationErrorsPanel(
                        trackedVerses: state.trackedVerses,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
