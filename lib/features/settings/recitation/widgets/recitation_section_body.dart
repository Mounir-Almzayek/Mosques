import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/quran/quran_tracking_page_view.dart';
import '../bloc/recitation_bloc.dart';
import '../bloc/recitation_event.dart';
import '../bloc/recitation_state.dart';
import 'recitation_event_card.dart';
import 'recitation_tracking_controls.dart';

class RecitationSectionBody extends StatefulWidget {
  const RecitationSectionBody({super.key});

  @override
  State<RecitationSectionBody> createState() => _RecitationSectionBodyState();
}

class _RecitationSectionBodyState extends State<RecitationSectionBody> {
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
              RecitationTrackingControls(
                state: state,
                surahController: _surahController,
                ayahController: _ayahController,
                onStartTracking: () {
                  context.read<RecitationBloc>().add(
                    StartRecitationTracking(
                      surah: int.tryParse(_surahController.text) ?? 1,
                      ayah: int.tryParse(_ayahController.text) ?? 1,
                    ),
                  );
                },
                onStopTracking: () {
                  context.read<RecitationBloc>().add(
                    const StopRecitationTracking(),
                  );
                },
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
                child: RecitationEventCard(event: state.lastEvent),
              ),
            ],
          );
        },
      ),
    );
  }
}
