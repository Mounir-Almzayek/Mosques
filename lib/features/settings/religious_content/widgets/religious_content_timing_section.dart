import 'package:flutter/material.dart';

import '../../../../data/models/mosque/display_settings.dart';
import '../../core/widgets/common_widgets.dart';

class ReligiousContentTimingSection extends StatelessWidget {
  final DisplaySettings design;
  final String waitLabel;
  final String displayLabel;
  final String suffix;
  final String title;
  final ValueChanged<int> onWaitChanged;
  final ValueChanged<int> onDisplayChanged;

  const ReligiousContentTimingSection({
    super.key,
    required this.design,
    required this.waitLabel,
    required this.displayLabel,
    required this.suffix,
    required this.title,
    required this.onWaitChanged,
    required this.onDisplayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(icon: Icons.timer_outlined, title: title),
        const SizedBox(height: 12),
        OffsetStepperField(
          label: waitLabel,
          value: design.religiousContentWaitSeconds,
          suffix: suffix,
          onChanged: onWaitChanged,
        ),
        OffsetStepperField(
          label: displayLabel,
          value: design.religiousContentDisplaySeconds,
          suffix: suffix,
          onChanged: onDisplayChanged,
        ),
      ],
    );
  }
}
