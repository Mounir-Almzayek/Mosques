import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';

class RecitationEventCard extends StatelessWidget {
  const RecitationEventCard({super.key, this.event});

  final Map<String, dynamic>? event;

  @override
  Widget build(BuildContext context) {
    final type = event?['type']?.toString() ?? 'idle';
    final body = event == null
        ? S.of(context).recitation_no_results
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
