import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/quran/quran_tracking_page_view.dart';
import '../../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../bloc/recitation_bloc.dart';
import '../bloc/recitation_event.dart';
import '../bloc/recitation_state.dart';
import '../data/recitation_ai_repository.dart';
import '../data/recitation_audio_streamer.dart';

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
      child: const _RecitationSectionBody(),
    );
  }
}

class _RecitationSectionBody extends StatefulWidget {
  const _RecitationSectionBody();

  @override
  State<_RecitationSectionBody> createState() => _RecitationSectionBodyState();
}

class _RecitationSectionBodyState extends State<_RecitationSectionBody> {
  final _surahController = TextEditingController(text: '1');
  final _ayahController = TextEditingController(text: '1');

  @override
  void dispose() {
    _surahController.dispose();
    _ayahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<RecitationBloc, RecitationState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'تتبع القراءة',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _surahController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'رقم السورة',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _ayahController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'رقم الآية',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppButton.elevated(
                      label: state.isTracking ? 'إيقاف التتبع' : 'بدء التتبع',
                      leadingIcon: state.isTracking
                          ? Icons.stop_rounded
                          : Icons.mic_rounded,
                      isLoading: state.isStarting,
                      disabled: state.isStarting,
                      onPressed: () {
                        final bloc = context.read<RecitationBloc>();
                        if (state.isTracking) {
                          bloc.add(const StopRecitationTracking());
                          return;
                        }
                        bloc.add(
                          StartRecitationTracking(
                            surah: int.tryParse(_surahController.text) ?? 1,
                            ayah: int.tryParse(_ayahController.text) ?? 1,
                          ),
                        );
                      },
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: QuranTrackingPageView(
                  currentPage: state.currentPage,
                  highlightedVerse: state.highlightedVerse,
                  onPageSelected: (page) {
                    context.read<RecitationBloc>().add(
                      RecitationPageSelected(page),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: _EventCard(event: state.lastEvent),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic>? event;

  const _EventCard({this.event});

  @override
  Widget build(BuildContext context) {
    final type = event?['type']?.toString() ?? 'idle';
    final body = event == null
        ? 'لم تصل نتائج بعد.'
        : event!.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0DDD4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(type, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(body, maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
