import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';

class AnnouncementEmptyState extends StatelessWidget {
  final S s;

  const AnnouncementEmptyState({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 72,
              color: scheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              s.announcement_empty_title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              s.announcement_empty_subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
