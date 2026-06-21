import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../bloc/recitation_state.dart';

class RecitationTrackingControls extends StatelessWidget {
  const RecitationTrackingControls({
    super.key,
    required this.state,
    required this.surahController,
    required this.ayahController,
    required this.onStartTracking,
    required this.onStopTracking,
  });

  final RecitationState state;
  final TextEditingController surahController;
  final TextEditingController ayahController;
  final VoidCallback onStartTracking;
  final VoidCallback onStopTracking;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.recitation_tracking_title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: surahController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: s.recitation_surah_number,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: ayahController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: s.recitation_ayah_number,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppButton.elevated(
            label: state.isTracking
                ? s.recitation_stop_tracking
                : s.recitation_start_tracking,
            leadingIcon: state.isTracking
                ? Icons.stop_rounded
                : Icons.mic_rounded,
            isLoading: state.isStarting,
            disabled: state.isStarting,
            onPressed: state.isTracking ? onStopTracking : onStartTracking,
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
}
