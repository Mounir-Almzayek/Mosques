import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/utils/color_converter.dart';

class DesignColorItem extends StatelessWidget {
  final String label;
  final String hexValue;
  final ValueChanged<String> onChanged;

  const DesignColorItem({
    super.key,
    required this.label,
    required this.hexValue,
    required this.onChanged,
  });

  void _showColorPicker(BuildContext context) {
    Color selectedColor = ColorConverter.fromHex(hexValue, Colors.blue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(label),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) => selectedColor = color,
              pickerAreaHeightPercent: 0.8,
              enableAlpha: true,
              displayThumbColor: true,
              hexInputBar: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context).cancel),
            ),
            ElevatedButton(
              onPressed: () {
                onChanged(ColorConverter.toHex(selectedColor));
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
    final currentColor = ColorConverter.fromHex(hexValue, Colors.grey);
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        hexValue.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
          fontSize: 13,
          fontFamily: 'monospace',
        ),
      ),
      trailing: GestureDetector(
        onTap: () => _showColorPicker(context),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
        ),
      ),
    );
  }
}
