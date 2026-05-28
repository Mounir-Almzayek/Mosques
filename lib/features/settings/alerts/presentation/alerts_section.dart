import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/alert_edit_dialog.dart';

/// Manages high-priority instant alerts with a saved-list + publish-on-demand flow.
///
/// Alerts are stored in [mosque.savedAlerts]. Each can be individually
/// published to the display for a configurable duration, then unpublished.
class AlertsSection extends StatelessWidget {
  final MosqueModel mosque;

  const AlertsSection({super.key, required this.mosque});

  // ── Helpers ─────────────────────────────────────────────────────────────

  static bool _isLive(AnnouncementModel alert) {
    if (!alert.isPublished || alert.publishedAt == null) return false;
    final expiry = alert.publishedAt!.add(
      Duration(seconds: alert.publishDurationSeconds),
    );
    return DateTime.now().isBefore(expiry);
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  void _openCreateDialog(BuildContext context) {
    final bloc = context.read<SettingsBloc>();
    showDialog(
      context: context,
      builder: (_) => AlertEditDialog(
        onAdd: (alert) {
          bloc.add(AlertAdded(alert));
          bloc.add(const SaveAlertsRequested());
        },
      ),
    );
  }

  void _openEditDialog(BuildContext context, AnnouncementModel alert) {
    final bloc = context.read<SettingsBloc>();
    showDialog(
      context: context,
      builder: (_) => AlertEditDialog(
        initialAlert: alert,
        onAdd: (updated) {
          bloc.add(AlertUpdated(updated));
          bloc.add(const SaveAlertsRequested());
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, AnnouncementModel alert) {
    final bloc = context.read<SettingsBloc>();
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.alert_delete),
        content: Text(alert.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () {
              bloc.add(AlertRemoved(alert.id));
              bloc.add(const SaveAlertsRequested());
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(s.alert_delete),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    final bloc = context.read<SettingsBloc>();
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.alerts_delete_all),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () {
              bloc.add(const AllAlertsDeleted());
              bloc.add(const SaveAlertsRequested());
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(s.alerts_delete_all),
          ),
        ],
      ),
    );
  }

  void _showPublishSheet(BuildContext context, AnnouncementModel alert) {
    final bloc = context.read<SettingsBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => _PublishBottomSheet(
        alert: alert,
        onPublish: (durationSeconds) {
          bloc.add(AlertPublished(alert.id, durationSeconds));
          bloc.add(const SaveAlertsRequested());
          Navigator.pop(sheetCtx);
        },
      ),
    );
  }

  void _unpublish(BuildContext context, AnnouncementModel alert) {
    final bloc = context.read<SettingsBloc>();
    bloc.add(AlertUnpublished(alert.id));
    bloc.add(const SaveAlertsRequested());
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final alerts = mosque.savedAlerts;

    return Scaffold(
      body: alerts.isEmpty
          ? _EmptyState(s: s)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: alerts.length,
              itemBuilder: (ctx, index) {
                final alert = alerts[index];
                final live = _isLive(alert);
                return AlertCard(
                  alert: alert,
                  isLive: live,
                  onPublish: () => _showPublishSheet(context, alert),
                  onUnpublish: () => _unpublish(context, alert),
                  onEdit: () => _openEditDialog(context, alert),
                  onDelete: () => _confirmDelete(context, alert),
                );
              },
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateDialog(context),
        icon: const Icon(Icons.add_alert_outlined),
        label: Text(s.alert_create),
        backgroundColor: const Color(0xFF1A3C34),
        foregroundColor: Colors.white,
      ),

      bottomNavigationBar: alerts.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDeleteAll(context),
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: Text(s.alerts_delete_all),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final S s;
  const _EmptyState({required this.s});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_alert_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              s.alerts_empty_title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              s.alerts_empty_subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Publish bottom sheet ─────────────────────────────────────────────────────

class _PublishBottomSheet extends StatefulWidget {
  final AnnouncementModel alert;
  final void Function(int durationSeconds) onPublish;

  const _PublishBottomSheet({
    required this.alert,
    required this.onPublish,
  });

  @override
  State<_PublishBottomSheet> createState() => _PublishBottomSheetState();
}

class _PublishBottomSheetState extends State<_PublishBottomSheet> {
  int _durationSeconds = 60;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        left: 24,
        right: 24,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Alert title
          Text(
            s.alert_publish,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.alert.title,
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 24),

          // Duration slider
          Row(
            children: [
              Text(
                s.alert_publish_duration,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '$_durationSeconds ${s.album_seconds_suffix}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Slider(
            value: _durationSeconds.toDouble(),
            min: 10,
            max: 300,
            divisions: 29,
            activeColor: const Color(0xFF1A3C34),
            onChanged: (v) => setState(() => _durationSeconds = v.toInt()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('10 ${s.album_seconds_suffix}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              Text('300 ${s.album_seconds_suffix}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),

          const SizedBox(height: 24),

          // Publish button
          FilledButton.icon(
            onPressed: () => widget.onPublish(_durationSeconds),
            icon: const Icon(Icons.play_circle_outline),
            label: Text(s.alert_publish),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A3C34),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
