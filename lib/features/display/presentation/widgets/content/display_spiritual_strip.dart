import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/utils/app_font_loader.dart';
import '../../../../../data/models/mosque_model.dart';
import '../../../../../data/models/mosque_text_entry_model.dart';
import '../../../../../data/models/mosque_text_list_kind.dart';
import 'typing_text_column.dart';

// ---------------------------------------------------------------------------
// Domain model for a slide in the spiritual strip
// ---------------------------------------------------------------------------

class _SpiritualSlide {
  final MosqueTextListKind kind;
  final MosqueTextEntryModel item;

  const _SpiritualSlide({required this.kind, required this.item});
}

// ---------------------------------------------------------------------------
// Strip below the prayer cards: random rotation + typing animation.
// ---------------------------------------------------------------------------

/// Displays hadiths, verses, duas, and adhkar in a rotating strip with
/// slide transitions and a typing-cursor effect on each entry.
class DisplaySpiritualStrip extends StatefulWidget {
  final MosqueModel mosque;
  final Color primaryColor;
  final Color cardColor;
  final double contentFontSize;

  const DisplaySpiritualStrip({
    super.key,
    required this.mosque,
    required this.primaryColor,
    required this.cardColor,
    required this.contentFontSize,
  });

  @override
  State<DisplaySpiritualStrip> createState() => _DisplaySpiritualStripState();
}

class _DisplaySpiritualStripState extends State<DisplaySpiritualStrip> {
  static const _rotateInterval = Duration(seconds: 14);
  static const _cream = Color(0xFFFFF8F0);

  final math.Random _random = math.Random();
  Timer? _timer;
  List<_SpiritualSlide> _pool = [];
  int _index = 0;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _rebuildPool();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant DisplaySpiritualStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mosque != widget.mosque) {
      setState(_rebuildPool);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Pool management
  // ---------------------------------------------------------------------------

  void _rebuildPool() {
    final next = _buildPool(widget.mosque);
    final prevLen = _pool.length;
    _pool = next;
    if (_pool.isEmpty) {
      _index = 0;
    } else if (prevLen == 0 || _index >= _pool.length) {
      _index = _random.nextInt(_pool.length);
    } else {
      _index = _index.clamp(0, _pool.length - 1);
    }
  }

  static List<_SpiritualSlide> _buildPool(MosqueModel mosque) {
    final out = <_SpiritualSlide>[];

    void addList(MosqueTextListKind kind, List<MosqueTextEntryModel> list) {
      for (final entry in list.where((e) => e.isActive)) {
        final body = _slideBodyText(entry);
        if (body.trim().isEmpty) continue;
        out.add(_SpiritualSlide(kind: kind, item: entry));
      }
    }

    addList(MosqueTextListKind.hadith, mosque.hadiths);
    addList(MosqueTextListKind.verse, mosque.verses);
    addList(MosqueTextListKind.dua, mosque.duas);
    addList(MosqueTextListKind.adhkar, mosque.adhkar);
    return out;
  }

  static String _slideBodyText(MosqueTextEntryModel h) {
    final b = StringBuffer();
    if (h.narrator.isNotEmpty) {
      b.write(h.narrator);
      b.write(' — ');
    }
    b.write(h.text);
    if (h.source.isNotEmpty) {
      b.write(' ');
      b.write(h.source);
    }
    return b.toString();
  }

  // ---------------------------------------------------------------------------
  // Timer
  // ---------------------------------------------------------------------------

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_rotateInterval, (_) {
      if (!mounted) return;
      _pickNextRandom();
    });
  }

  void _pickNextRandom() {
    if (_pool.isEmpty) return;
    if (_pool.length == 1) {
      setState(() {});
      return;
    }
    int next;
    do {
      next = _random.nextInt(_pool.length);
    } while (next == _index);
    setState(() => _index = next);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String _labelForKind(MosqueTextListKind kind, S s) {
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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_pool.isEmpty) return const SizedBox.shrink();

    final s = S.of(context);
    final slide = _pool[_index];
    final dir = Directionality.of(context);
    final label = _labelForKind(slide.kind, s);
    final base = widget.contentFontSize;

    final labelFs = (base * 1.1).clamp(15.0, 24.0);
    final contextFs = (base * 1.05).clamp(14.0, 22.0);
    final bodyFs = (base * 2.1).clamp(24.0, 52.0);
    final sourceFs = (base * 0.95).clamp(13.0, 20.0);

    final p = widget.primaryColor;
    final c = widget.cardColor;

    final fillA = Color.lerp(c, Colors.white, 0.06)!.withValues(alpha: 0.6);
    final fillB = c.withValues(alpha: 0.6);

    return LayoutBuilder(
      builder: (context, stripConstraints) {
        final stripW = stripConstraints.maxWidth;
        final narrow = stripW < 600;
        final labelMinW = narrow ? 64.0 : 80.0;
        final labelMaxW = narrow ? 100.0 : 120.0;
        final padOuter = EdgeInsets.only(
          top: narrow ? 10 : 14,
          bottom: narrow ? 6 : 10,
        );
        final padInner = EdgeInsets.symmetric(
          horizontal: (stripW * 0.04).clamp(16.0, 42.0),
          vertical: (base * 0.7).clamp(16.0, 32.0),
        );

        return Padding(
          padding: padOuter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 520),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Container(
              key: ValueKey<String>(
                '${slide.kind.name}_${slide.item.id}_$_index',
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [fillA, fillB],
                ),
                border: Border.all(color: p.withValues(alpha: 0.14), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: p.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              Colors.white.withValues(alpha: 0.06),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: padInner,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        textDirection: dir,
                        children: [
                          _buildKindLabel(
                            p,
                            label,
                            labelFs,
                            labelMinW,
                            labelMaxW,
                            narrow,
                          ),
                          const SizedBox(width: 10),
                          _buildVerticalDivider(p),
                          const SizedBox(width: 10),
                          Flexible(
                            child: TypingTextColumn(
                              key: ValueKey<Object>(
                                Object.hash(slide.item.id, slide.kind, _index),
                              ),
                              item: slide.item,
                              primaryColor: p,
                              contextFs: contextFs,
                              bodyFs: bodyFs,
                              sourceFs: sourceFs,
                              design: widget.mosque.designSettings,
                            ),
                          ),
                        ],
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
  }

  Widget _buildKindLabel(
    Color primary,
    String label,
    double fontSize,
    double minW,
    double maxW,
    bool narrow,
  ) {
    final fontFamily = widget.mosque.designSettings.fontFamily;
    return Container(
      constraints: BoxConstraints(minWidth: minW, maxWidth: maxW),
      padding: EdgeInsets.symmetric(
        horizontal: narrow ? 6 : 8,
        vertical: narrow ? 8 : 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primary, Color.lerp(primary, Colors.black, 0.12)!],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppFontLoader.getStyle(
              fontFamily,
              baseStyle: TextStyle(
                color: _cream,
                fontWeight: FontWeight.w800,
                fontSize: fontSize,
                height: 1.1,
                letterSpacing: 0.15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDivider(Color primary) {
    return Container(
      width: 2,
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primary.withValues(alpha: 0.15),
            primary.withValues(alpha: 0.45),
            primary.withValues(alpha: 0.15),
          ],
        ),
      ),
    );
  }
}
