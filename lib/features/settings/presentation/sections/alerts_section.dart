import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../../bloc/settings/settings_bloc.dart';
import 'widgets/alert_card.dart';
import 'widgets/alert_edit_dialog.dart';

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
                return AlertCard(alert: alert, bloc: bloc);
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
                  bloc.add(const AlertsCleared());
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
      builder: (context) => AlertEditDialog(
        onAdd: (alert) {
          bloc.add(AlertAdded(alert));
          bloc.add(const SaveAlertsRequested());
        },
      ),
    );
  }
}


