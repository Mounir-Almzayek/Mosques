import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/utils/app_font_loader.dart';
import '../../../../data/models/mosque/mosque_model.dart';

/// Inline religious content (hadith, verse, dua, adhkar) rendered inside the
/// beige area instead of as a fullscreen overlay.
///
/// Reuses the same content-selection and typewriter-animation logic as
/// [ReligiousContentLayer], but uses [inactiveCardTextValue] for text color
/// and scales fonts via [religiousContentFontSize].
class ReligiousContentInline extends StatefulWidget {
  final MosqueModel mosque;
  final DesignSettingsModel designSettings;
  final int slideIndex;
  final double religiousContentFontSize;

  const ReligiousContentInline({
    super.key,
    required this.mosque,
    required this.designSettings,
    required this.slideIndex,
    required this.religiousContentFontSize,
  });

  @override
  State<ReligiousContentInline> createState() =>
      _ReligiousContentInlineState();
}

class _ReligiousContentInlineState extends State<ReligiousContentInline>
    with SingleTickerProviderStateMixin {
  late MosqueTextEntryModel _current;
  late AnimationController _controller;

  static const Duration _charDuration = Duration(milliseconds: 35);

  @override
  void initState() {
    super.initState();
    _current = _pickSlide();
    _controller = AnimationController(
      vsync: this,
      duration: _charDuration * _current.text.length,
    )..forward();
  }

  @override
  void didUpdateWidget(covariant ReligiousContentInline oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-pick when the cycle advances or the content pool changes.
    if (oldWidget.slideIndex != widget.slideIndex ||
        oldWidget.mosque != widget.mosque) {
      final newSlide = _pickSlide();
      setState(() => _current = newSlide);
      _controller
        ..duration = _charDuration * _current.text.length
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Picks a random active entry from all content lists.
  MosqueTextEntryModel _pickSlide() {
    final pool = <MosqueTextEntryModel>[
      ...widget.mosque.hadiths,
      ...widget.mosque.verses,
      ...widget.mosque.duas,
      ...widget.mosque.adhkar,
    ].where((e) => e.isActive && e.text.isNotEmpty).toList();

    if (pool.isEmpty) {
      return const MosqueTextEntryModel(
        id: '_empty',
        narrator: '',
        text: '',
        source: '',
      );
    }

    final rng = Random(widget.slideIndex);
    return pool[rng.nextInt(pool.length)];
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.designSettings.colors;
    final textColor = colors.inactiveCardTextValue;

    final baseStyle = AppFontLoader.getStyle(
      widget.designSettings.fontFamily,
      baseStyle: TextStyle(color: textColor),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Typewriter text
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final fullText = _current.text;
                final charCount =
                    (_controller.value * fullText.length).round();
                final visible = fullText.substring(0, charCount);
                return Center(
                  child: Text(
                    visible,
                    style: baseStyle.copyWith(
                      fontSize: (widget.religiousContentFontSize * 2.1)
                          .clamp(14.0, 80.0),
                      fontWeight: FontWeight.w400,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                );
              },
            ),
          ),

          // Source line
          if (_current.source.isNotEmpty)
            Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: Text(
                _current.source,
                style: baseStyle.copyWith(
                  fontSize: (widget.religiousContentFontSize * 1.1)
                      .clamp(10.0, 42.0),
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
        ],
      ),
    );
  }
}
