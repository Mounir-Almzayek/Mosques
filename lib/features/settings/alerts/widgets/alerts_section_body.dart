import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../bloc/alerts_bloc.dart';
import 'alert_card.dart';
import 'alert_edit_dialog.dart';
import 'alert_publish_bottom_sheet.dart';
import 'alerts_delete_all_bar.dart';
import 'alerts_empty_state.dart';

class AlertsSectionBody extends StatelessWidget {
  const AlertsSectionBody({super.key});

  static bool _isLive(AnnouncementModel alert) {
    if (!alert.isPublished || alert.publishedAt == null) return false;

    final expiry = alert.publishedAt!.add(
      Duration(seconds: alert.publishDurationSeconds),
    );
    return DateTime.now().isBefore(expiry);
  }

  void _openCreateDialog(BuildContext context) {
    final bloc = context.read<AlertsBloc>();
    showDialog<void>(
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
    final bloc = context.read<AlertsBloc>();
    showDialog<void>(
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
    final bloc = context.read<AlertsBloc>();
    final s = S.of(context);
    showDialog<void>(
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
    final bloc = context.read<AlertsBloc>();
    final s = S.of(context);
    showDialog<void>(
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
    final bloc = context.read<AlertsBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => AlertPublishBottomSheet(
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
    final bloc = context.read<AlertsBloc>();
    bloc.add(AlertUnpublished(alert.id));
    bloc.add(const SaveAlertsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<AlertsBloc, AlertsState>(
      listenWhen: (prev, curr) =>
          prev.isSaving != curr.isSaving ||
          (curr.error != null && prev.error == null),
      listener: (context, state) {
        if (state.isSaving) {
          UnifiedSnackbar.info(context, message: s.saving);
        } else if (state.error != null) {
          UnifiedSnackbar.error(context, message: state.error!);
        } else {
          UnifiedSnackbar.hide(context);
          UnifiedSnackbar.success(context, message: s.saved_successfully);
        }
      },
      child: BlocBuilder<AlertsBloc, AlertsState>(
        builder: (context, state) {
          final mosque = state.mosque;
          if (mosque == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = mosque.savedAlerts;

          return Scaffold(
            body: alerts.isEmpty
                ? AlertsEmptyState(s: s)
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
                ? AlertsDeleteAllBar(
                    s: s,
                    onDeleteAll: () => _confirmDeleteAll(context),
                  )
                : null,
          );
        },
      ),
    );
  }
}
