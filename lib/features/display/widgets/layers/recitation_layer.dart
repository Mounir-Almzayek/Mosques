import 'package:flutter/material.dart';

import '../../../../core/widgets/quran/quran_tracking_page_view.dart';
import '../../bloc/display_state.dart';
import 'recitation_header.dart';

class RecitationLayer extends StatelessWidget {
  final DisplayRecitationState recitation;

  const RecitationLayer({super.key, required this.recitation});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFECE8DE),
      child: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RecitationHeader(event: recitation.event),
              Expanded(
                child: QuranTrackingPageView(
                  currentPage: recitation.currentPage,
                  highlightedVerse: recitation.highlightedVerse,
                  onPageSelected: (_) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
