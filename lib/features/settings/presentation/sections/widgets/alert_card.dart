import 'package:flutter/material.dart';

import '../../../../../data/models/mosque/announcement_model.dart';
import '../../../bloc/settings/settings_bloc.dart';

class AlertCard extends StatelessWidget {
  final AnnouncementModel alert;
  final SettingsBloc bloc;

  const AlertCard({super.key, required this.alert, required this.bloc});

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
            bloc.add(AlertRemoved(alert.id));
            bloc.add(const SaveAlertsRequested());
          },
        ),
      ),
    );
  }
}
