import 'package:flutter/material.dart';

import '../../../../core/enums/settings/announcement_schedule.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../data/models/mosque/mosque_bootstrap.dart';
import 'announcement_status_chip.dart';

class AnnouncementListItem extends StatelessWidget {
  final Announcement announcement;
  final AnnouncementSchedule status;
  final S s;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AnnouncementListItem({
    super.key,
    required this.announcement,
    required this.status,
    required this.s,
    required this.onActiveChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isActive = announcement.isActive;

    return Material(
      key: ValueKey('announcement_${announcement.id}'),
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      announcement.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isActive ? AppColors.primary : scheme.outline,
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(value: isActive, onChanged: onActiveChanged),
                  ),
                  const SizedBox(width: 4),
                  AnnouncementStatusChip(status: status, s: s),
                ],
              ),
              if (announcement.subtitle != null &&
                  announcement.subtitle!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Opacity(
                  opacity: isActive ? 1.0 : 0.6,
                  child: Text(
                    announcement.subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Opacity(
                opacity: isActive ? 1.0 : 0.6,
                child: Row(
                  children: [
                    Icon(
                      Icons.date_range_outlined,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${_dateLabel(announcement.startAt)} -> ${_dateLabel(announcement.endAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(s.edit),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: scheme.error,
                    ),
                    label: Text(
                      s.delete,
                      style: TextStyle(color: scheme.error),
                    ),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateLabel(DateTime value) {
    return value.toLocal().toString().split(' ').first;
  }
}
