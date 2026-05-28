import 'package:flutter/material.dart';
import '../../../../core/enums/app_numeral_format.dart';
import '../../../../core/l10n/generated/l10n.dart';
import 'design_card.dart';
import 'font_browser_dialog.dart';

class TypographySettingsSection extends StatelessWidget {
  final String fontFamily;
  final AppNumeralFormat numeralFormat;
  final ValueChanged<String> onFontFamilyChanged;
  final ValueChanged<AppNumeralFormat> onNumeralFormatChanged;

  const TypographySettingsSection({
    super.key,
    required this.fontFamily,
    required this.numeralFormat,
    required this.onFontFamilyChanged,
    required this.onNumeralFormatChanged,
  });

  void _showFontBrowser(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FontBrowserDialog(
        selectedFont: fontFamily,
        onFontSelected: onFontFamilyChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DesignSectionTitle(
            title: s.design_typography_title,
            icon: Icons.font_download_rounded,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(s.design_font_family),
            subtitle: Text(fontFamily),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showFontBrowser(context),
          ),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            s.design_numeral_format,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 12),
          SegmentedButton<AppNumeralFormat>(
            segments: [
              ButtonSegment(
                value: AppNumeralFormat.arabic,
                label: Text(s.numeral_format_arabic),
                icon: const Icon(Icons.language_rounded),
              ),
              ButtonSegment(
                value: AppNumeralFormat.english,
                label: Text(s.numeral_format_english),
                icon: const Icon(Icons.numbers_rounded),
              ),
            ],
            selected: {numeralFormat},
            onSelectionChanged: (vals) => onNumeralFormatChanged(vals.first),
            showSelectedIcon: false,
          ),
        ],
      ),
    );
  }
}
