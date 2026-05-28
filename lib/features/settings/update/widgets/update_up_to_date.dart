import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';

class UpdateUpToDate extends StatelessWidget {
  final ThemeData theme;
  final S s;

  const UpdateUpToDate({super.key, required this.theme, required this.s});

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.verified_rounded, size: 44, color: primary),
            ),
            const SizedBox(height: 16),
            Text(
              s.update_up_to_date,
              style: theme.textTheme.titleMedium?.copyWith(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
