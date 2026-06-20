import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/mosque/announcement.dart';
import 'alert_status_badge.dart';

/// A card that displays a saved alert with its live/ready status and actions.
class AlertCard extends StatelessWidget {
  final Announcement alert;
  final bool isLive;
  final VoidCallback onPublish;
  final VoidCallback onUnpublish;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AlertCard({
    super.key,
    required this.alert,
    required this.isLive,
    required this.onPublish,
    required this.onUnpublish,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isLive ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isLive
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    alert.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AlertStatusBadge(isLive: isLive, s: s),
              ],
            ),

            // Subtitle
            if (alert.subtitle != null && alert.subtitle!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                alert.subtitle!,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            // Action row
            Row(
              children: [
                // Publish / Unpublish button
                Expanded(
                  child: isLive
                      ? OutlinedButton.icon(
                          onPressed: onUnpublish,
                          icon: const Icon(
                            Icons.stop_circle_outlined,
                            size: 18,
                          ),
                          label: Text(
                            s.alert_unpublish,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: onPublish,
                          icon: const Icon(Icons.play_circle_outline, size: 18),
                          label: Text(
                            s.alert_publish,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1A3C34),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 4),

                // Edit
                IconButton(
                  tooltip: s.alert_edit,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: onEdit,
                  color: colorScheme.onSurfaceVariant,
                ),

                // Delete
                IconButton(
                  tooltip: s.alert_delete,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                  color: colorScheme.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
