import 'package:flutter/material.dart';

import '../../../../core/enums/settings/announcement_schedule.dart';
import '../../../../core/l10n/generated/l10n.dart';

class AnnouncementStatusChip extends StatelessWidget {
  final AnnouncementSchedule status;
  final S s;

  const AnnouncementStatusChip({
    super.key,
    required this.status,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    late Color backgroundColor;
    late Color foregroundColor;
    late String label;

    switch (status) {
      case AnnouncementSchedule.active:
        backgroundColor = Colors.green.withValues(alpha: 0.15);
        foregroundColor = Colors.green.shade800;
        label = s.announcement_status_active;
        break;
      case AnnouncementSchedule.upcoming:
        backgroundColor = scheme.primaryContainer.withValues(alpha: 0.7);
        foregroundColor = scheme.onPrimaryContainer;
        label = s.announcement_status_upcoming;
        break;
      case AnnouncementSchedule.ended:
        backgroundColor = scheme.surfaceContainerHighest;
        foregroundColor = scheme.onSurfaceVariant;
        label = s.announcement_status_ended;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
