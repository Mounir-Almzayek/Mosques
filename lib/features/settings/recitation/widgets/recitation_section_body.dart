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
  int _selectedSurah = 1;
  int _selectedAyah = 1;

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
                selectedSurah: _selectedSurah,
                selectedAyah: _selectedAyah,
                onSurahChanged: (value) {
                  setState(() {
                    _selectedSurah = value;
                    _selectedAyah = 1;
                  });
                },
                onAyahChanged: (value) {
                  setState(() {
                    _selectedAyah = value;
                  });
                },
                onStartTracking: () {
                  context.read<RecitationBloc>().add(
                    StartRecitationTracking(
                      surah: _selectedSurah,
                      ayah: _selectedAyah,
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
