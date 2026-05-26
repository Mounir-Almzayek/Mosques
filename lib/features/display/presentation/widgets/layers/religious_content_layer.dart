import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/utils/app_font_loader.dart';
import '../../../../../data/models/mosque/mosque_model.dart';

/// Fullscreen overlay showing religious content (hadith, verse, dua, adhkar)
/// with a typewriter character-by-character animation.
///
/// Each time [slideIndex] changes a new random entry is picked from the
/// combined pool of active texts. The text appears one character at a time
/// at 35 ms per character.
class ReligiousContentLayer extends StatefulWidget {
  final MosqueModel mosque;
  final DesignSettingsModel designSettings;
  final int slideIndex;

  const ReligiousContentLayer({
    super.key,
    required this.mosque,
    required this.designSettings,
    required this.slideIndex,
  });

  @override
  State<ReligiousContentLayer> createState() => _ReligiousContentLayerState();
}

class _ReligiousContentLayerState extends State<ReligiousContentLayer>
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
  void didUpdateWidget(covariant ReligiousContentLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slideIndex != widget.slideIndex) {
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

    final rng = Random(widget.slideIndex);
    return pool[rng.nextInt(pool.length)];
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = widget.designSettings.colors;
    final bgColor = colors.primaryValue;
    final textColor = colors.secondaryValue;

    final baseStyle = AppFontLoader.getStyle(
      widget.designSettings.fontFamily,
      baseStyle: TextStyle(color: textColor),
    );

    final kindLabel = _kindLabel(_current.kind, s);

    return Container(
      color: bgColor,
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kind badge
          Align(
            alignment: AlignmentDirectional.topStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                kindLabel,
                style: baseStyle.copyWith(fontSize: 20),
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
                    fontSize: 42,
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
                  fontSize: 22,
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
