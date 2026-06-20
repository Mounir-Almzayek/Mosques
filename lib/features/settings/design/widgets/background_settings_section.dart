import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../core/enums/display_background_type.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/utils/color_converter.dart';
import 'album_url_list.dart';
import 'design_card.dart';
import 'design_section_title.dart';
import 'display_background_picker.dart';

class BackgroundSettingsSection extends StatelessWidget {
  final DisplayBackgroundType backgroundType;
  final String backgroundValue;
  final ValueChanged<DisplayBackgroundType> onTypeChanged;
  final ValueChanged<String> onValueChanged;
  final List<String> albumUrls;
  final ValueChanged<String> onAlbumUrlAdded;
  final void Function(int) onAlbumUrlRemoved;

  /// Available background images from the global library (app config).
  final List<String> libraryUrls;

  const BackgroundSettingsSection({
    super.key,
    required this.backgroundType,
    required this.backgroundValue,
    required this.onTypeChanged,
    required this.onValueChanged,
    required this.albumUrls,
    required this.onAlbumUrlAdded,
    required this.onAlbumUrlRemoved,
    this.libraryUrls = const [],
  });

  void _showColorPicker(BuildContext context) {
    Color selectedColor = ColorConverter.fromHex(backgroundValue, Colors.blue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            S.of(context).design_color_primary,
          ), // Reuse for translation
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
            AppButton.elevated(
              label: S.of(context).save,
              onPressed: () {
                onValueChanged(ColorConverter.toHex(selectedColor));
                Navigator.pop(context);
              },
              height: 40,
              borderRadius: 12,
              expand: false,
              useShadow: false,
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
            selected: {backgroundType},
            onSelectionChanged: (vals) => onTypeChanged(vals.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 20),
          if (backgroundType == DisplayBackgroundType.color)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(s.design_bg_type_color),
              subtitle: Text(backgroundValue),
              trailing: GestureDetector(
                onTap: () => _showColorPicker(context),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ColorConverter.fromHex(backgroundValue, Colors.grey),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (backgroundType == DisplayBackgroundType.album)
            AlbumUrlList(
              urls: albumUrls,
              onUrlAdded: onAlbumUrlAdded,
              onUrlRemoved: onAlbumUrlRemoved,
            )
          else
            DisplayBackgroundPicker(
              selectedValue: backgroundValue,
              libraryUrls: libraryUrls,
              onSelected: onValueChanged,
            ),
        ],
      ),
    );
  }
}
