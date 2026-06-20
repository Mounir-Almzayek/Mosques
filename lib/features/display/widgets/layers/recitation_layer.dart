import 'package:flutter/material.dart';

import '../../../../core/widgets/quran/quran_tracking_page_view.dart';
import '../../bloc/display_state.dart';

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
              _RecitationHeader(event: recitation.event),
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

class _RecitationHeader extends StatelessWidget {
  final Map<String, dynamic> event;

  const _RecitationHeader({required this.event});

  @override
  Widget build(BuildContext context) {
    final type = event['type']?.toString() ?? '';
    final title = switch (type) {
      'error' => 'ملاحظة على قراءة الإمام',
      _ => 'تتبع قراءة الإمام',
    };
    final details = _details();
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF123735)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                details,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _details() {
    final surah = event['surah']?.toString();
    final ayah = event['ayah']?.toString();
    final state = event['state']?.toString();
    final message = event['message']?.toString();
    final confidence = (event['confidence'] as num?)?.toDouble();
    return [
      if (surah != null && ayah != null) 'السورة $surah - الآية $ayah',
      if (state != null && state != 'listening') state,
      if (message != null && message.isNotEmpty) message,
      if (confidence != null) 'الثقة ${(confidence * 100).round()}%',
    ].join('   ');
  }
}
