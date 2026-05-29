import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/utils/app_font_loader.dart';
import '../../../../data/models/mosque/mosque_model.dart';

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
  final double religiousContentFontSize;

  const ReligiousContentLayer({
    super.key,
    required this.mosque,
    required this.designSettings,
    required this.slideIndex,
    required this.religiousContentFontSize,
  });

  @override
  State<ReligiousContentLayer> createState() => _ReligiousContentLayerState();
}

class _ReligiousContentLayerState extends State<ReligiousContentLayer>
    with SingleTickerProviderStateMixin {
  late MosqueTextEntryModel _current;
  late bool _isQuran;
  late AnimationController _controller;

  static const Duration _charDuration = Duration(milliseconds: 35);

  @override
  void initState() {
    super.initState();
    final slide = _pickSlide();
    _current = slide.entry;
    _isQuran = slide.isQuran;
    _controller = AnimationController(
      vsync: this,
      duration: _charDuration * _current.text.length,
    )..forward();
  }

  @override
  void didUpdateWidget(covariant ReligiousContentLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slideIndex != widget.slideIndex) {
      final newSlide = _pickSlide();
      setState(() {
        _current = newSlide.entry;
        _isQuran = newSlide.isQuran;
      });
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

  /// Picks a random active entry from all content lists, tagging whether it
  /// came from the Qur'an verses list (so verse text uses the Uthmanic font).
  ({MosqueTextEntryModel entry, bool isQuran}) _pickSlide() {
    final pool = <({MosqueTextEntryModel entry, bool isQuran})>[
      ...widget.mosque.hadiths.map((e) => (entry: e, isQuran: false)),
      ...widget.mosque.verses.map((e) => (entry: e, isQuran: true)),
      ...widget.mosque.duas.map((e) => (entry: e, isQuran: false)),
      ...widget.mosque.adhkar.map((e) => (entry: e, isQuran: false)),
    ].where((p) => p.entry.isActive && p.entry.text.isNotEmpty).toList();

    if (pool.isEmpty) {
      return (
        entry: const MosqueTextEntryModel(
          id: '_empty',
          narrator: '',
          text: '',
          source: '',
        ),
        isQuran: false,
      );
    }

    final rng = Random(widget.slideIndex);
    return pool[rng.nextInt(pool.length)];
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.designSettings.colors;
    final bgColor = colors.primaryValue;
    final textColor = colors.secondaryValue;

    // Verses render with a Qur'an-capable font so Uthmanic marks survive;
    // everything else keeps the mosque's chosen display font.
    final baseStyle = _isQuran
        ? AppFontLoader.getQuranStyle(baseStyle: TextStyle(color: textColor))
        : AppFontLoader.getStyle(
            widget.designSettings.fontFamily,
            baseStyle: TextStyle(color: textColor),
          );

    return Container(
      color: bgColor,
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
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
                      fontWeight: FontWeight.w700,
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
                  fontWeight: FontWeight.w600,
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
