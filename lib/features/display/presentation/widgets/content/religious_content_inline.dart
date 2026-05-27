import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/utils/app_font_loader.dart';
import '../../../../../data/models/mosque/mosque_model.dart';

/// Inline religious content (hadith, verse, dua, adhkar) rendered inside the
/// beige area instead of as a fullscreen overlay.
///
/// Reuses the same content-selection and typewriter-animation logic as
/// [ReligiousContentLayer], but uses [inactiveCardTextValue] for text color
/// and scales fonts via [religiousContentFontSize].
class ReligiousContentInline extends StatefulWidget {
  final MosqueModel mosque;
  final DesignSettingsModel designSettings;
  final double religiousContentFontSize;

  const ReligiousContentInline({
    super.key,
    required this.mosque,
    required this.designSettings,
    required this.religiousContentFontSize,
  });

  @override
  State<ReligiousContentInline> createState() =>
      _ReligiousContentInlineState();
}

class _ReligiousContentInlineState extends State<ReligiousContentInline>
    with SingleTickerProviderStateMixin {
  late _SlideContent _current;
  late AnimationController _controller;

  static const Duration _charDuration = Duration(milliseconds: 35);

  @override
  void initState() {
    super.initState();
    _current = _pickSlide();
    _controller = AnimationController(
      vsync: this,
      duration: _charDuration * _current.entry.text.length,
    )..forward();
  }

  @override
  void didUpdateWidget(covariant ReligiousContentInline oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-pick a slide when the mosque data changes (new content pool).
    if (oldWidget.mosque != widget.mosque) {
      final newSlide = _pickSlide();
      setState(() => _current = newSlide);
      _controller
        ..duration = _charDuration * _current.entry.text.length
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Picks a random active entry from all content lists.
  _SlideContent _pickSlide() {
    final pool = <_SlideContent>[];

    void addKind(List<MosqueTextEntryModel> items, MosqueTextListKind kind) {
      for (final item in items) {
        if (item.isActive && item.text.isNotEmpty) {
          pool.add(_SlideContent(entry: item, kind: kind));
        }
      }
    }

    addKind(widget.mosque.hadiths, MosqueTextListKind.hadith);
    addKind(widget.mosque.verses, MosqueTextListKind.verse);
    addKind(widget.mosque.duas, MosqueTextListKind.dua);
    addKind(widget.mosque.adhkar, MosqueTextListKind.adhkar);

    if (pool.isEmpty) {
      return _SlideContent(
        entry: const MosqueTextEntryModel(
          id: '_empty',
          narrator: '',
          text: '',
          source: '',
        ),
        kind: MosqueTextListKind.hadith,
      );
    }

    final rng = Random();
    return pool[rng.nextInt(pool.length)];
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = widget.designSettings.colors;
    final textColor = colors.inactiveCardTextValue;

    final baseStyle = AppFontLoader.getStyle(
      widget.designSettings.fontFamily,
      baseStyle: TextStyle(color: textColor),
    );

    final kindLabel = _kindLabel(_current.kind, s);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kind badge
          Align(
            alignment: AlignmentDirectional.topStart,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                kindLabel,
                style: baseStyle.copyWith(
                  fontSize: (widget.religiousContentFontSize * 1.0)
                      .clamp(10.0, 38.0),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Typewriter text
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final fullText = _current.entry.text;
                final charCount =
                    (_controller.value * fullText.length).round();
                final visible = fullText.substring(0, charCount);
                return Text(
                  visible,
                  style: baseStyle.copyWith(
                    fontSize: (widget.religiousContentFontSize * 2.1)
                        .clamp(14.0, 80.0),
                    height: 1.8,
                  ),
                  textDirection: TextDirection.rtl,
                );
              },
            ),
          ),

          // Source line
          if (_current.entry.source.isNotEmpty)
            Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: Text(
                _current.entry.source,
                style: baseStyle.copyWith(
                  fontSize: (widget.religiousContentFontSize * 1.1)
                      .clamp(10.0, 42.0),
                  fontStyle: FontStyle.italic,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
        ],
      ),
    );
  }

  String _kindLabel(MosqueTextListKind kind, S s) {
    switch (kind) {
      case MosqueTextListKind.hadith:
        return s.display_ticker_hadith;
      case MosqueTextListKind.verse:
        return s.display_ticker_verse;
      case MosqueTextListKind.dua:
        return s.display_ticker_dua;
      case MosqueTextListKind.adhkar:
        return s.display_ticker_adhkar;
    }
  }
}

/// Internal pairing of a text entry with its content kind.
class _SlideContent {
  final MosqueTextEntryModel entry;
  final MosqueTextListKind kind;

  const _SlideContent({required this.entry, required this.kind});
}
