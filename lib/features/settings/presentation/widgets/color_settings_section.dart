import 'package:flutter/material.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/design_color_settings.dart';
import 'design_card.dart';
import 'design_color_item.dart';

class ColorSettingsSection extends StatelessWidget {
  final DesignColorSettings colors;
  final ValueChanged<String> onPrimaryChanged;
  final ValueChanged<String> onSecondaryChanged;
  final ValueChanged<String> onActiveCardChanged;
  final ValueChanged<String> onActiveCardTextChanged;
  final ValueChanged<String> onInactiveCardTextChanged;
  final ValueChanged<String> onPrayerOverlayChanged;

  const ColorSettingsSection({
    super.key,
    required this.colors,
    required this.onPrimaryChanged,
    required this.onSecondaryChanged,
    required this.onActiveCardChanged,
    required this.onActiveCardTextChanged,
    required this.onInactiveCardTextChanged,
    required this.onPrayerOverlayChanged,
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
            hexValue: colors.primary,
            onChanged: onPrimaryChanged,
          ),
          const Divider(),
          DesignColorItem(
            label: s.design_color_secondary,
            hexValue: colors.secondary,
            onChanged: onSecondaryChanged,
          ),
          const Divider(),
          DesignColorItem(
            label: s.design_color_active_card,
            hexValue: colors.activeCard,
            onChanged: onActiveCardChanged,
          ),
          const Divider(),
          DesignColorItem(
            label: s.design_color_active_card_text,
            hexValue: colors.activeCardText,
            onChanged: onActiveCardTextChanged,
          ),
          const Divider(),
          DesignColorItem(
            label: s.design_color_inactive_card_text,
            hexValue: colors.inactiveCardText,
            onChanged: onInactiveCardTextChanged,
          ),
          const Divider(),
          DesignColorItem(
            label: s.design_color_prayer_overlay,
            hexValue: colors.prayerOverlay,
            onChanged: onPrayerOverlayChanged,
          ),
        ],
      ),
    );
  }
}
