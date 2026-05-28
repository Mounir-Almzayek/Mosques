import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';

class AlertsDeleteAllBar extends StatelessWidget {
  final S s;
  final VoidCallback onDeleteAll;

  const AlertsDeleteAllBar({
    super.key,
    required this.s,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: OutlinedButton.icon(
          onPressed: onDeleteAll,
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
    );
  }
}
