import 'package:flutter/material.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../bloc/recitation_state.dart';

class RecitationTrackingControls extends StatelessWidget {
  const RecitationTrackingControls({
    super.key,
    required this.state,
    required this.selectedSurah,
    required this.selectedAyah,
    required this.onSurahChanged,
    required this.onAyahChanged,
    required this.onStartTracking,
    required this.onStopTracking,
  });

  final RecitationState state;
  final int selectedSurah;
  final int selectedAyah;
  final ValueChanged<int> onSurahChanged;
  final ValueChanged<int> onAyahChanged;
  final VoidCallback onStartTracking;
  final VoidCallback onStopTracking;

  static final List<_RecitationSurahOption> _surahs = List.generate(114, (
    index,
  ) {
    final number = index + 1;
    return _RecitationSurahOption(
      number: number,
      nameAr: getSurahNameArabic(number),
      nameEn: getSurahNameEnglish(number),
      verseCount: getVerseCount(number),
    );
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final selected = _surahs[selectedSurah - 1];
    final ayah = selectedAyah.clamp(1, selected.verseCount).toInt();
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.recitation_tracking_title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          _SurahSearchField(
            options: _surahs,
            selected: selected,
            enabled: !state.isTracking && !state.isStarting,
            onSelected: (option) => onSurahChanged(option.number),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Container(
              key: ValueKey(selected.number),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: .55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.recitation_ayah_number,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '$ayah / ${selected.verseCount}',
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: ayah.toDouble(),
                    min: 1,
                    max: selected.verseCount.toDouble(),
                    divisions: selected.verseCount > 1
                        ? selected.verseCount - 1
                        : null,
                    label: '$ayah',
                    onChanged: state.isTracking || state.isStarting
                        ? null
                        : (value) => onAyahChanged(value.round()),
                  ),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        tooltip: s.recitation_ayah_number,
                        onPressed:
                            state.isTracking || state.isStarting || ayah <= 1
                            ? null
                            : () => onAyahChanged(ayah - 1),
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          getVerse(selected.number, ayah),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filledTonal(
                        tooltip: s.recitation_ayah_number,
                        onPressed:
                            state.isTracking ||
                                state.isStarting ||
                                ayah >= selected.verseCount
                            ? null
                            : () => onAyahChanged(ayah + 1),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton.elevated(
            label: state.isTracking
                ? s.recitation_stop_tracking
                : s.recitation_start_tracking,
            leadingIcon: state.isTracking
                ? Icons.stop_rounded
                : Icons.mic_rounded,
            isLoading: state.isStarting,
            disabled: state.isStarting,
            onPressed: state.isTracking ? onStopTracking : onStartTracking,
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
}

class _SurahSearchField extends StatefulWidget {
  const _SurahSearchField({
    required this.options,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final List<_RecitationSurahOption> options;
  final _RecitationSurahOption selected;
  final bool enabled;
  final ValueChanged<_RecitationSurahOption> onSelected;

  @override
  State<_SurahSearchField> createState() => _SurahSearchFieldState();
}

class _SurahSearchFieldState extends State<_SurahSearchField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selected.displayName);
    _focusNode = FocusNode();
    _focusNode.addListener(_resetTextWhenUnfocused);
  }

  @override
  void didUpdateWidget(covariant _SurahSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected.number != widget.selected.number &&
        !_focusNode.hasFocus) {
      _controller.text = widget.selected.displayName;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_resetTextWhenUnfocused);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _resetTextWhenUnfocused() {
    if (_focusNode.hasFocus) return;
    if (_controller.text == widget.selected.displayName) return;
    _controller.text = widget.selected.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = Theme.of(context).colorScheme;

    return RawAutocomplete<_RecitationSurahOption>(
      textEditingController: _controller,
      focusNode: _focusNode,
      displayStringForOption: (option) => option.displayName,
      optionsBuilder: (value) {
        final query = _normalize(value.text);
        if (query.isEmpty) return widget.options;
        return widget.options.where((option) => option.matches(query));
      },
      onSelected: (option) {
        _controller.text = option.displayName;
        widget.onSelected(option);
      },
      fieldViewBuilder:
          (context, fieldController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: fieldController,
              focusNode: focusNode,
              enabled: widget.enabled,
              decoration: InputDecoration(
                labelText: s.recitation_surah_number,
                hintText: s.verse_narrator,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: const Icon(Icons.expand_more_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          },
      optionsViewBuilder: (context, onSelected, options) {
        final items = options.toList(growable: false);
        final width = MediaQuery.sizeOf(context).width - 40;
        return Align(
          alignment: Alignment.topRight,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: width,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: colors.outlineVariant),
                  itemBuilder: (context, index) {
                    final option = items[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 18,
                        child: Text('${option.number}'),
                      ),
                      title: Text(option.nameAr),
                      subtitle: Text('${option.nameEn} - ${option.verseCount}'),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RecitationSurahOption {
  final int number;
  final String nameAr;
  final String nameEn;
  final int verseCount;

  const _RecitationSurahOption({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.verseCount,
  });

  String get displayName => '$number - $nameAr';

  bool matches(String query) {
    return _normalize('$number $nameAr $nameEn').contains(query);
  }
}

String _normalize(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[\\u064B-\\u065F\\u0670]'), '')
      .replaceAll('\u0623', '\u0627')
      .replaceAll('\u0625', '\u0627')
      .replaceAll('\u0622', '\u0627')
      .replaceAll('\u0671', '\u0627')
      .replaceAll('\u0649', '\u064A')
      .replaceAll('\u0629', '\u0647');
}
