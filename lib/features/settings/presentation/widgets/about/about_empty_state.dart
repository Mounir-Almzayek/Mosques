import 'package:flutter/material.dart';
import '../../../../../core/l10n/generated/l10n.dart';

class AboutEmptyState extends StatelessWidget {
  const AboutEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            s.no_data,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
