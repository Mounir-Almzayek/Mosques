import 'package:flutter/material.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/mosque/display_settings.dart';
import 'design_card.dart';
import 'design_section_title.dart';
import 'design_color_item.dart';

class ColorSettingsSection extends StatelessWidget {
  final DisplaySettings colors;
  final ValueChanged<String> onPrimaryChanged;
  final ValueChanged<String> onSecondaryChanged;
  final ValueChanged<String> onActiveCardChanged;
  final ValueChanged<String> onActiveCardTextChanged;
  final ValueChanged<String> onInactiveCardTextChanged;
  final ValueChanged<String> onPrayerOverlayChanged;
  final ValueChanged<String> onCountdownBackgroundChanged;
  final ValueChanged<String> onCountdownTextChanged;
  final ValueChanged<String> onAlertBackgroundChanged;
  final ValueChanged<String> onAlertTextChanged;

  const ColorSettingsSection({
    super.key,
    required this.colors,
    required this.onPrimaryChanged,
    required this.onSecondaryChanged,
    required this.onActiveCardChanged,
    required this.onActiveCardTextChanged,
    required this.onInactiveCardTextChanged,
    required this.onPrayerOverlayChanged,
    required this.onCountdownBackgroundChanged,
    required this.onCountdownTextChanged,
    required this.onAlertBackgroundChanged,
    required this.onAlertTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DesignSectionTitle(
            title: s.design_colors_title,
            icon: Icons.palette_rounded,
          ),
          DesignColorItem(
            label: s.design_color_primary,
            hexValue: colors.primaryColor,
            onChanged: onPrimaryChanged,
          ),
          const Divider(),
          DesignColorItem(
            label: s.design_color_secondary,
            hexValue: colors.secondaryColor,
            onChanged: onSecondaryChanged,
          ),
          const Divider(),
          DesignColorItem(
            label: s.design_color_active_card,
            hexValue: colors.activeCardColor,
            onChanged: onActiveCardChanged,
          ),
          const Divider(),
          DesignColorItem(
            label: s.design_color_active_card_text,
            hexValue: colors.activeCardTextColor,
            onChanged: onActiveCardTextChanged,
          ),
          const Divider(),
          DesignColorItem(
            label: s.design_color_inactive_card_text,
            hexValue: colors.inactiveCardTextColor,
            onChanged: onInactiveCardTextChanged,
          ),
          const Divider(),
          DesignColorItem(
            label: s.design_color_prayer_overlay,
            hexValue: colors.prayerOverlayColor,
            onChanged: onPrayerOverlayChanged,
          ),
          const Divider(),
          DesignColorItem(
            label: s.design_color_countdown_background,
            hexValue: colors.countdownBackgroundColor,
            onChanged: onCountdownBackgroundChanged,
          ),
          const Divider(),
          DesignColorItem(
            label: s.design_color_countdown_text,
            hexValue: colors.countdownTextColor,
            onChanged: onCountdownTextChanged,
          ),
          const Divider(),
          DesignColorItem(
            label: s.design_color_alert_background,
            hexValue: colors.alertBackgroundColor,
            onChanged: onAlertBackgroundChanged,
          ),
          const Divider(),
          DesignColorItem(
            label: s.design_color_alert_text,
            hexValue: colors.alertTextColor,
            onChanged: onAlertTextChanged,
          ),
        ],
      ),
    );
  }
}
