import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/font_preset.dart';
import '../../../../core/l10n/generated/l10n.dart';

/// Visual font browser to select from Google Fonts with live previews.
class FontBrowserDialog extends StatefulWidget {
  final String selectedFont;
  final void Function(String) onFontSelected;

  const FontBrowserDialog({
    super.key,
    required this.selectedFont,
    required this.onFontSelected,
  });

  @override
  State<FontBrowserDialog> createState() => _FontBrowserDialogState();
}

class _FontBrowserDialogState extends State<FontBrowserDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(s.design_font_browser_title),
      content: SizedBox(
        width: 400,
        height: 500,
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: ListView.separated(
            controller: _scrollController,
            itemCount: FontPreset.values.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final font = FontPreset.values[i];
              final isSelected = font.name == widget.selectedFont;
              
              return InkWell(
                onTap: () {
                  widget.onFontSelected(font.name);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primaryColor.withOpacity(0.1) : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              font.displayName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Direct preview using GoogleFonts
                            Text(
                              s.design_font_preview_text,
                              style: GoogleFonts.getFont(
                                font.name,
                                textStyle: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: theme.primaryColor),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
      ],
    );
  }
}

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
