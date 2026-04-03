import 'package:flutter/material.dart';
import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../data/models/font_size_settings.dart';
import 'design_card.dart';
import 'design_font_size_item.dart';

class FontSizeSettingsSection extends StatelessWidget {
  final FontSizeSettings fontSizes;
  final ValueChanged<double> onClockSizeChanged;
  final ValueChanged<double> onMosqueInfoSizeChanged;
  final ValueChanged<double> onPrayersSizeChanged;
  final ValueChanged<double> onAnnouncementsSizeChanged;
  final ValueChanged<double> onContentSizeChanged;

  const FontSizeSettingsSection({
    super.key,
    required this.fontSizes,
    required this.onClockSizeChanged,
    required this.onMosqueInfoSizeChanged,
    required this.onPrayersSizeChanged,
    required this.onAnnouncementsSizeChanged,
    required this.onContentSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DesignSectionTitle(
            title: s.design_font_sizes_title,
            icon: Icons.text_fields_rounded,
          ),
          DesignFontSizeItem(
            label: s.design_clock_font_size,
            value: fontSizes.clock,
            onChanged: onClockSizeChanged,
            icon: Icons.access_time_rounded,
          ),
          DesignFontSizeItem(
            label: s.design_mosque_info_font_size,
            value: fontSizes.mosqueInfo,
            onChanged: onMosqueInfoSizeChanged,
            icon: Icons.info_outline_rounded,
          ),
          DesignFontSizeItem(
            label: s.design_prayers_font_size,
            value: fontSizes.prayers,
            onChanged: onPrayersSizeChanged,
            icon: Icons.mosque_rounded,
          ),
          DesignFontSizeItem(
            label: s.design_announcements_font_size,
            value: fontSizes.announcements,
            onChanged: onAnnouncementsSizeChanged,
            icon: Icons.campaign_outlined,
          ),
          DesignFontSizeItem(
            label: s.design_content_font_size,
            value: fontSizes.content,
            onChanged: onContentSizeChanged,
            icon: Icons.description_outlined,
          ),
        ],
      ),
    );
  }
}
