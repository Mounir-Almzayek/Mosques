import 'package:flutter/material.dart';
import '../../../../core/config/font_preset.dart';
import '../../../../core/l10n/generated/l10n.dart';
import 'font_browser_dialog.dart';

/// A button that displays the current font and opens the browser.
class FontSelectorButton extends StatelessWidget {
  final String currentFont;
  final void Function(String) onFontSelected;

  const FontSelectorButton({
    super.key,
    required this.currentFont,
    required this.onFontSelected,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final font = FontPreset.values.firstWhere(
      (f) => f.name == currentFont,
      orElse: () => FontPreset.values.first,
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(s.design_font_family),
      subtitle: Text(font.displayName),
      trailing: FilledButton.tonalIcon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => FontBrowserDialog(
              selectedFont: currentFont,
              onFontSelected: onFontSelected,
            ),
          );
        },
        icon: const Icon(Icons.font_download_outlined),
        label: Text(s.design_font_browse),
      ),
    );
  }
}
