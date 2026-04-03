import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/mosque_model.dart';
import '../../../../data/models/announcement_model.dart';
import '../../bloc/settings/settings_bloc.dart';

/// Manage high-priority instant alerts to be shown on the mosque display screen.
class AlertsSection extends StatelessWidget {
  final MosqueModel mosque;

  const AlertsSection({super.key, required this.mosque});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SettingsBloc>();
    final s = S.of(context);
    final alerts = mosque.activeAlerts;

    return Scaffold(
      body: alerts.isEmpty
          ? Center(
              child: Text(
                '${s.alerts_empty_title}\n${s.alerts_empty_subtitle}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _AlertCard(alert: alert, bloc: bloc);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAlert(context, bloc),
        icon: const Icon(Icons.emergency_share),
        label: Text(s.alerts_fab_add),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: alerts.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.tonalIcon(
                onPressed: () {
                  bloc.add(const SettingsAlertsCleared());
                  bloc.add(const SaveAlertsRequested());
                },
                icon: const Icon(Icons.clear_all),
                label: Text(s.alerts_clear_all),
              ),
            )
          : null,
    );
  }

  void _showAddAlert(BuildContext context, SettingsBloc bloc) {
    showDialog(
      context: context,
      builder: (context) => _AlertEditDialog(
        onAdd: (alert) {
          bloc.add(SettingsAlertAdded(alert));
          bloc.add(const SaveAlertsRequested());
        },
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AnnouncementModel alert;
  final SettingsBloc bloc;

  const _AlertCard({required this.alert, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          alert.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(alert.subtitle ?? ''),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.grey),
          onPressed: () {
            bloc.add(SettingsAlertRemoved(alert.id));
            bloc.add(const SaveAlertsRequested());
          },
        ),
      ),
    );
  }
}

class _AlertEditDialog extends StatefulWidget {
  final void Function(AnnouncementModel) onAdd;

  const _AlertEditDialog({required this.onAdd});

  @override
  State<_AlertEditDialog> createState() => _AlertEditDialogState();
}

class _AlertEditDialogState extends State<_AlertEditDialog> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  int _seconds = 30;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      title: Text(s.alert_editor_title),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(labelText: s.alert_field_headline),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentCtrl,
              decoration: InputDecoration(labelText: s.alert_field_message),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(s.alert_field_duration),
                Expanded(
                  child: Slider(
                    value: _seconds.toDouble(),
                    min: 10,
                    max: 600,
                    divisions: 59,
                    onChanged: (v) => setState(() => _seconds = v.toInt()),
                  ),
                ),
                Text('$_seconds ${s.unit_seconds}'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_titleCtrl.text.isNotEmpty && _contentCtrl.text.isNotEmpty) {
              final now = DateTime.now();
              final alert = AnnouncementModel(
                id: const Uuid().v4(),
                title: _titleCtrl.text,
                subtitle: _contentCtrl.text,
                startDate: now,
                endDate: now.add(const Duration(hours: 4)), // Temporary alert
                isPriority: true,
                displayDurationSeconds: _seconds,
                isActive: true,
              );
              widget.onAdd(alert);
              Navigator.pop(context);
            }
          },
          child: Text(s.alert_send_action),
        ),
      ],
    );
  }
}
