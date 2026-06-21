import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';

class RecitationHeader extends StatelessWidget {
  const RecitationHeader({super.key, required this.event});

  final Map<String, dynamic> event;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final type = event['type']?.toString() ?? '';
    final title = switch (type) {
      'error' => s.recitation_imam_error_title,
      _ => s.recitation_imam_tracking_title,
    };
    final details = _details(s);

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

  String _details(S s) {
    final surah = event['surah']?.toString();
    final ayah = event['ayah']?.toString();
    final state = event['state']?.toString();
    final message = event['message']?.toString();
    final confidence = (event['confidence'] as num?)?.toDouble();
    return [
      if (surah != null && ayah != null)
        s.recitation_position_detail(surah, ayah),
      if (state != null && state != 'listening') state,
      if (message != null && message.isNotEmpty) message,
      if (confidence != null)
        s.recitation_confidence_detail((confidence * 100).round()),
    ].join('   ');
  }
}
