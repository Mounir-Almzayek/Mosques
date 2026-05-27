import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../../core/enums/display_background_type.dart';
import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/utils/color_converter.dart';
import '../../../../../data/models/design/design_background_settings.dart';
import 'design_card.dart';
import 'display_background_picker.dart';

class BackgroundSettingsSection extends StatelessWidget {
  final DesignBackgroundSettings settings;
  final ValueChanged<DisplayBackgroundType> onTypeChanged;
  final ValueChanged<String> onValueChanged;
  final List<String> albumUrls;
  final ValueChanged<String> onAlbumUrlAdded;
  final void Function(int) onAlbumUrlRemoved;

  const BackgroundSettingsSection({
    super.key,
    required this.settings,
    required this.onTypeChanged,
    required this.onValueChanged,
    required this.albumUrls,
    required this.onAlbumUrlAdded,
    required this.onAlbumUrlRemoved,
  });

  void _showColorPicker(BuildContext context) {
    Color selectedColor = ColorConverter.fromHex(settings.value, Colors.blue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.of(context).design_color_primary), // Reuse for translation
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) => selectedColor = color,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context).cancel),
            ),
            ElevatedButton(
              onPressed: () {
                onValueChanged(ColorConverter.toHex(selectedColor));
                Navigator.pop(context);
              },
              child: Text(S.of(context).save),
            ),
          ],
        );
      },
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
            title: s.design_background_title,
            icon: Icons.wallpaper_rounded,
          ),
          SegmentedButton<DisplayBackgroundType>(
            segments: [
              ButtonSegment(
                value: DisplayBackgroundType.image,
                label: Text(s.design_bg_type_image),
                icon: const Icon(Icons.image_outlined),
              ),
              ButtonSegment(
                value: DisplayBackgroundType.color,
                label: Text(s.design_bg_type_color),
                icon: const Icon(Icons.format_color_fill_outlined),
              ),
              ButtonSegment(
                value: DisplayBackgroundType.album,
                label: Text(s.design_bg_type_album),
                icon: const Icon(Icons.photo_library_outlined),
              ),
            ],
            selected: {settings.type},
            onSelectionChanged: (vals) => onTypeChanged(vals.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 20),
          if (settings.type == DisplayBackgroundType.color)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(s.design_bg_type_color),
              subtitle: Text(settings.value),
              trailing: GestureDetector(
                onTap: () => _showColorPicker(context),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ColorConverter.fromHex(settings.value, Colors.grey),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      )
                    ],
                  ),
                ),
              ),
            )
          else if (settings.type == DisplayBackgroundType.album)
            _AlbumUrlList(
              urls: albumUrls,
              onUrlAdded: onAlbumUrlAdded,
              onUrlRemoved: onAlbumUrlRemoved,
            )
          else
            SizedBox(
              height: 120,
              child: DisplayBackgroundPicker(
                selectedValue: settings.value,
                onSelected: onValueChanged,
              ),
            ),
        ],
      ),
    );
  }
}

class _AlbumUrlList extends StatelessWidget {
  final List<String> urls;
  final ValueChanged<String> onUrlAdded;
  final void Function(int) onUrlRemoved;

  const _AlbumUrlList({
    required this.urls,
    required this.onUrlAdded,
    required this.onUrlRemoved,
  });

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).photo_studio_add_url),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'https://example.com/image.jpg',
            labelText: S.of(context).url_label,
          ),
          keyboardType: TextInputType.url,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) onUrlAdded(url);
              Navigator.pop(ctx);
            },
            child: Text(S.of(context).add_label),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...urls.asMap().entries.map((entry) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              entry.value,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, size: 40),
            ),
          ),
          title: Text(entry.value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => onUrlRemoved(entry.key),
          ),
        )),
        TextButton.icon(
          onPressed: () => _showAddDialog(context),
          icon: const Icon(Icons.add),
          label: Text(S.of(context).add_label),
        ),
      ],
    );
  }
}
