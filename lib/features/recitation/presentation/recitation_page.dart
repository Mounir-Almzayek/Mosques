import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/imam_tracking_repository.dart';
import 'bloc/recitation_bloc.dart';
import 'bloc/recitation_event.dart';
import 'bloc/recitation_state.dart';
import 'widgets/iman_tracking_header.dart';
import 'widgets/quran_tracking_page_view.dart';
import 'widgets/recording_button.dart';

class RecitationPage extends StatelessWidget {
  const RecitationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImamTrackingBloc>(
      create: (_) =>
          ImamTrackingBloc(repository: ImamTrackingRepository())
            ..add(const LoadImamTracking()),
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
                  ImamTrackingHeader(
                    isRecording: state.isRecording,
                    currentPage: state.currentPage,
                    totalPages: state.totalPages,
                    lastRecordedAt: state.lastRecordedAt,
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: QuranTrackingPageView(
                      currentPage: state.currentPage,
                      trackedVerses: state.trackedVerses,
                      onPageSelected: (pageNumber) {
                        context.read<ImamTrackingBloc>().add(
                          SelectPage(pageNumber),
                        );
                      },
                      onVerseRead: (surahNumber, verseNumber) {
                        context.read<ImamTrackingBloc>().add(
                          MarkVerseRead(surahNumber, verseNumber),
                        );
                      },
                      onVerseIncorrect: (surahNumber, verseNumber) {
                        context.read<ImamTrackingBloc>().add(
                          MarkVerseIncorrect(surahNumber, verseNumber),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  RecordingButton(
                    isRecording: state.isRecording,
                    onPressed: () {
                      context.read<ImamTrackingBloc>().add(
                        const ToggleRecording(),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'اضغط على الآية لتحديدها كمقروءة، واضغط مطولًا لتحديد خطأ.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF66716C), fontSize: 13),
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
