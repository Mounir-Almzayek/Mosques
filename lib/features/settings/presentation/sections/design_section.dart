import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../../core/enums/display_background_preset.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/mosque_model.dart';
import '../../bloc/settings_bloc.dart';

String _displayBackgroundLabel(DisplayBackgroundPreset p, S s) {
  switch (p) {
    case DisplayBackgroundPreset.mosqueDisplayPrimary:
      return s.design_bg_primary;
    case DisplayBackgroundPreset.mosqueDisplay01:
      return s.design_bg_style_1;
    case DisplayBackgroundPreset.mosqueDisplay02:
      return s.design_bg_style_2;
    case DisplayBackgroundPreset.mosqueDisplay03:
      return s.design_bg_style_3;
    case DisplayBackgroundPreset.mosqueDisplay04:
      return s.design_bg_style_4;
    case DisplayBackgroundPreset.mosqueDisplay05:
      return s.design_bg_style_5;
    case DisplayBackgroundPreset.mosqueDisplayBrand:
      return s.design_bg_brand;
  }
}

Color _colorFromHex(String hex) {
  var s = hex.replaceAll('#', '').trim();
  if (s.isEmpty) s = 'FFFFFF';
  if (s.length == 6) s = 'FF$s';
  return Color(int.parse(s, radix: 16));
}

String _hexFromColor(Color c, {bool includeAlpha = false}) {
  if (includeAlpha) {
    final a = (c.a * 255.0).round().clamp(0, 255);
    final r = (c.r * 255.0).round().clamp(0, 255);
    final g = (c.g * 255.0).round().clamp(0, 255);
    final b = (c.b * 255.0).round().clamp(0, 255);
    return '#${a.toRadixString(16).padLeft(2, '0')}'
            '${r.toRadixString(16).padLeft(2, '0')}'
            '${g.toRadixString(16).padLeft(2, '0')}'
            '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }
  final r = (c.r * 255.0).round().clamp(0, 255);
  final g = (c.g * 255.0).round().clamp(0, 255);
  final b = (c.b * 255.0).round().clamp(0, 255);
  return '#${r.toRadixString(16).padLeft(2, '0')}'
          '${g.toRadixString(16).padLeft(2, '0')}'
          '${b.toRadixString(16).padLeft(2, '0')}'
      .toUpperCase();
}

class DesignSection extends StatefulWidget {
  final MosqueModel mosque;

  const DesignSection({super.key, required this.mosque});

  @override
  State<DesignSection> createState() => _DesignSectionState();
}

class _DesignSectionState extends State<DesignSection> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fontSizeCtrl;

  @override
  void initState() {
    super.initState();
    _fontSizeCtrl = TextEditingController(
      text: widget.mosque.designSettings.baseFontSize.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant DesignSection oldWidget) {
    if (oldWidget.mosque.designSettings != widget.mosque.designSettings) {
      _fontSizeCtrl.text = widget.mosque.designSettings.baseFontSize.toString();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _fontSizeCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      context.read<SettingsBloc>().add(const SaveDesignSettingsRequested());
    }
  }

  Future<void> _showColorPicker({
    required String title,
    required Color initial,
    required void Function(String hex) onApply,
    bool includeAlpha = false,
  }) async {
    Color pickerColor = initial;
    final s = S.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setSt) {
              return ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (c) {
                  setSt(() => pickerColor = c);
                },
                pickerAreaHeightPercent: 0.65,
                displayThumbColor: true,
                enableAlpha: includeAlpha,
                hexInputBar: true,
                labelTypes: const [ColorLabelType.rgb, ColorLabelType.hsv],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.save),
          ),
        ],
      ),
    );
    if (result == true) {
      onApply(_hexFromColor(pickerColor, includeAlpha: includeAlpha));
    }
  }

  Widget _colorRow({
    required S s,
    required String label,
    required String hex,
    required void Function(String) onApply,
    bool includeAlpha = false,
  }) {
    Color c;
    try {
      c = _colorFromHex(hex);
    } catch (_) {
      c = Colors.grey;
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black26),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonal(
            onPressed: () => _showColorPicker(
              title: s.design_pick_color,
              initial: c,
              onApply: onApply,
              includeAlpha: includeAlpha,
            ),
            child: Text(s.design_pick_color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SettingsBloc>();
    final s = S.of(context);
    final d = widget.mosque.designSettings;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DisplayBackgroundPicker(
            bloc: bloc,
            s: s,
            selectedId: d.backgroundValue,
          ),
          const SizedBox(height: 24),
          _colorRow(
            s: s,
            label: s.design_primary_color,
            hex: d.primaryColor,
            onApply: (h) => bloc.add(SettingsDesignPrimaryColorChanged(h)),
          ),
          const SizedBox(height: 8),
          _colorRow(
            s: s,
            label: s.design_secondary_color,
            hex: d.secondaryColor,
            onApply: (h) => bloc.add(SettingsDesignSecondaryColorChanged(h)),
          ),
          const SizedBox(height: 16),
          _colorRow(
            s: s,
            label: s.design_prayer_overlay,
            hex: d.prayerOverlayColor,
            onApply: (h) => bloc.add(SettingsDesignPrayerOverlayChanged(h)),
            includeAlpha: true,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _fontSizeCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: s.design_base_font_size),
            validator: (v) {
              if (v == null || v.isEmpty) return s.required_field;
              final n = double.tryParse(v);
              if (n == null || n < 8 || n > 96) {
                return s.validation_font_size_range;
              }
              return null;
            },
            onChanged: (v) {
              final n = double.tryParse(v);
              if (n != null) bloc.add(SettingsDesignBaseFontSizeChanged(n));
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _save(),
            child: Text(s.save_design_settings),
          ),
        ],
      ),
    );
  }
}

class _DisplayBackgroundPicker extends StatelessWidget {
  final SettingsBloc bloc;
  final S s;
  final String selectedId;

  const _DisplayBackgroundPicker({
    required this.bloc,
    required this.s,
    required this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    final selected = DisplayBackgroundPreset.fromStorageId(selectedId);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.design_display_background_image,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, c) {
            final cross = c.maxWidth > 520 ? 4 : 3;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.05,
              ),
              itemCount: DisplayBackgroundPreset.values.length,
              itemBuilder: (context, i) {
                final p = DisplayBackgroundPreset.values[i];
                final isSel = p == selected;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => bloc.add(
                      SettingsDesignBackgroundValueChanged(p.storageId),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel
                              ? theme.colorScheme.primary
                              : Colors.black26,
                          width: isSel ? 3 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Image.asset(
                                p.assetPath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    ColoredBox(color: Colors.grey.shade300),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 6,
                              ),
                              child: Text(
                                _displayBackgroundLabel(p, s),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
