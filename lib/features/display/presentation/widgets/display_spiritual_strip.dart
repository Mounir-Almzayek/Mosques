import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/mosque_model.dart';

class _SpiritualSlide {
  final MosqueTextListKind kind;
  final MosqueTextEntryModel item;

  const _SpiritualSlide({required this.kind, required this.item});
}

String _slideBodyText(MosqueTextEntryModel h) {
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

List<_SpiritualSlide> _buildPool(MosqueModel mosque) {
  final out = <_SpiritualSlide>[];
  void addList(MosqueTextListKind kind, List<MosqueTextEntryModel> list) {
    for (final h in list.where((e) => e.isActive)) {
      final t = _slideBodyText(h);
      if (t.trim().isEmpty) continue;
      out.add(_SpiritualSlide(kind: kind, item: h));
    }
  }

  addList(MosqueTextListKind.hadith, mosque.hadiths);
  addList(MosqueTextListKind.verse, mosque.verses);
  addList(MosqueTextListKind.dua, mosque.duas);
  addList(MosqueTextListKind.adhkar, mosque.adhkar);
  return out;
}

String _labelForKind(MosqueTextListKind kind, S s) {
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

String _graphemePrefix(String s, int count) {
  if (count <= 0 || s.isEmpty) return '';
  final ch = Characters(s);
  final b = StringBuffer();
  var i = 0;
  for (final g in ch) {
    if (i >= count) break;
    b.write(g);
    i++;
  }
  return b.toString();
}

int _graphemeLength(String s) => Characters(s).length;

/// شريط أسفل بطاقات الصلاة: تناوب عشوائي + تأثير كتابة للنص.
class DisplaySpiritualStrip extends StatefulWidget {
  final MosqueModel mosque;
  final Color primaryColor;
  final Color cardColor;
  final double baseFontSize;

  const DisplaySpiritualStrip({
    super.key,
    required this.mosque,
    required this.primaryColor,
    required this.cardColor,
    required this.baseFontSize,
  });

  @override
  State<DisplaySpiritualStrip> createState() => _DisplaySpiritualStripState();
}

class _DisplaySpiritualStripState extends State<DisplaySpiritualStrip> {
  static const _rotate = Duration(seconds: 14);
  static const _cream = Color(0xFFFFF8F0);

  final math.Random _random = math.Random();
  Timer? _timer;
  List<_SpiritualSlide> _pool = [];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _rebuildPool();
    _startTimer();
  }

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

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_rotate, (_) {
      if (!mounted) return;
      _pickNextRandom();
    });
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

  @override
  Widget build(BuildContext context) {
    if (_pool.isEmpty) {
      return const SizedBox.shrink();
    }

    final s = S.of(context);
    final slide = _pool[_index];
    final dir = Directionality.of(context);
    final label = _labelForKind(slide.kind, s);
    final base = widget.baseFontSize;

    final labelFs = (base * 1.12).clamp(12.0, 22.0);
    final contextFs = (base * 1.02).clamp(11.0, 19.0);
    final bodyFs = (base * 1.32).clamp(14.0, 28.0);
    final sourceFs = (base * 0.95).clamp(10.0, 18.0);

    final p = widget.primaryColor;
    final c = widget.cardColor;

    /// شفافية فقط لخلفية البطاقة — دون تخفيف ألوان النص أو عنوان التصنيف.
    final fillA = Color.lerp(c, Colors.white, 0.06)!.withValues(alpha: 0.44);
    final fillB = c.withValues(alpha: 0.36);

    return LayoutBuilder(
      builder: (context, stripConstraints) {
        final stripW = stripConstraints.maxWidth;
        final narrow = stripW < 560;
        final labelMinW = narrow ? 58.0 : 72.0;
        final labelMaxW = narrow ? 92.0 : 108.0;
        final padOuter = EdgeInsets.only(
          top: narrow ? 8 : 12,
          bottom: narrow ? 4 : 6,
        );
        final padInner = EdgeInsets.symmetric(
          horizontal: (stripW * 0.028).clamp(8.0, 16.0),
          vertical: narrow ? 10.0 : 14.0,
        );

        return Padding(
          padding: padOuter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 520),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final fade = FadeTransition(opacity: animation, child: child);
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
                child: fade,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: dir,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              minWidth: labelMinW,
                              maxWidth: labelMaxW,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: narrow ? 6 : 8,
                              vertical: narrow ? 8 : 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [p, Color.lerp(p, Colors.black, 0.12)!],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: p.withValues(alpha: 0.28),
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
                                  style: TextStyle(
                                    color: _cream,
                                    fontWeight: FontWeight.w800,
                                    fontSize: labelFs,
                                    fontFamily: 'Beiruti',
                                    height: 1.1,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 2,
                            margin: const EdgeInsets.only(top: 4, bottom: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  p.withValues(alpha: 0.15),
                                  p.withValues(alpha: 0.45),
                                  p.withValues(alpha: 0.15),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TypingTextColumn(
                              key: ValueKey<Object>(
                                Object.hash(slide.item.id, slide.kind, _index),
                              ),
                              item: slide.item,
                              primaryColor: p,
                              contextFs: contextFs,
                              bodyFs: bodyFs,
                              sourceFs: sourceFs,
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
}

/// نص يظهر حرفاً بحرف (حسب الحروف المرئية للعربية) مع وميض مؤشر أثناء الكتابة.
class _TypingTextColumn extends StatefulWidget {
  const _TypingTextColumn({
    super.key,
    required this.item,
    required this.primaryColor,
    required this.contextFs,
    required this.bodyFs,
    required this.sourceFs,
  });

  final MosqueTextEntryModel item;
  final Color primaryColor;
  final double contextFs;
  final double bodyFs;
  final double sourceFs;

  @override
  State<_TypingTextColumn> createState() => _TypingTextColumnState();
}

class _TypingTextColumnState extends State<_TypingTextColumn> {
  static const _tick = Duration(milliseconds: 26);

  Timer? _typeTimer;
  Timer? _caretTimer;

  late String _narrator;
  late String _text;
  late String _source;
  int _nLen = 0;
  int _tLen = 0;
  int _sLen = 0;

  /// 0 = نص السياق، 1 = النص الرئيسي، 2 = المصدر، 3 = انتهى
  int _stage = 0;
  bool _caretVisible = true;

  int get _nMax => _graphemeLength(_narrator);
  int get _tMax => _graphemeLength(_text);
  int get _sMax => _graphemeLength(_source);

  bool get _typingDone => _stage >= 3;

  @override
  void initState() {
    super.initState();
    _initStrings();
    _startCaretBlink();
    _startTyping();
  }

  @override
  void didUpdateWidget(covariant _TypingTextColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.text != widget.item.text) {
      _typeTimer?.cancel();
      _initStrings();
      _startTyping();
    }
  }

  void _initStrings() {
    _narrator = widget.item.narrator.trim();
    _text = widget.item.text;
    _source = widget.item.source.trim();
    _nLen = 0;
    _tLen = 0;
    _sLen = 0;

    if (_nMax > 0) {
      _stage = 0;
    } else if (_tMax > 0) {
      _stage = 1;
    } else if (_sMax > 0) {
      _stage = 2;
    } else {
      _stage = 3;
    }
  }

  void _startCaretBlink() {
    _caretTimer?.cancel();
    _caretTimer = Timer.periodic(const Duration(milliseconds: 480), (_) {
      if (!mounted || _typingDone) return;
      setState(() => _caretVisible = !_caretVisible);
    });
  }

  int _burstForRemaining(int remaining) {
    if (remaining > 320) return 5;
    if (remaining > 160) return 3;
    if (remaining > 70) return 2;
    return 1;
  }

  void _startTyping() {
    _typeTimer?.cancel();
    _typeTimer = Timer.periodic(_tick, (_) {
      if (!mounted) return;
      if (_stage >= 3) {
        _typeTimer?.cancel();
        _caretTimer?.cancel();
        return;
      }

      setState(() {
        if (_stage == 0) {
          final rem = _nMax - _nLen;
          _nLen = (_nLen + _burstForRemaining(rem)).clamp(0, _nMax);
          if (_nLen >= _nMax) {
            _stage = _tMax > 0 ? 1 : (_sMax > 0 ? 2 : 3);
          }
          return;
        }
        if (_stage == 1) {
          final rem = _tMax - _tLen;
          _tLen = (_tLen + _burstForRemaining(rem)).clamp(0, _tMax);
          if (_tLen >= _tMax) {
            _stage = _sMax > 0 ? 2 : 3;
          }
          return;
        }
        if (_stage == 2) {
          final rem = _sMax - _sLen;
          _sLen = (_sLen + _burstForRemaining(rem)).clamp(0, _sMax);
          if (_sLen >= _sMax) _stage = 3;
        }
      });
    });
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _caretTimer?.cancel();
    super.dispose();
  }

  Widget _typedLine({
    required String full,
    required int visible,
    required TextStyle style,
    required bool caretHere,
  }) {
    final prefix = _graphemePrefix(full, visible);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: prefix),
          if (caretHere && !_typingDone && _caretVisible)
            TextSpan(
              text: ' ▌',
              style: style.copyWith(
                fontWeight: FontWeight.w300,
                color: style.color?.withValues(alpha: 0.65),
              ),
            ),
        ],
      ),
      textAlign: TextAlign.start,
      maxLines: 8,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.primaryColor;
    final ctxStyle = TextStyle(
      color: p.withValues(alpha: 0.78),
      fontWeight: FontWeight.w600,
      fontSize: widget.contextFs,
      fontFamily: 'Beiruti',
      height: 1.35,
    );
    final bodyStyle = TextStyle(
      color: p.withValues(alpha: 0.96),
      fontWeight: FontWeight.w700,
      fontSize: widget.bodyFs,
      fontFamily: 'Beiruti',
      height: 1.5,
      letterSpacing: 0.12,
    );
    final srcStyle = TextStyle(
      color: p.withValues(alpha: 0.58),
      fontWeight: FontWeight.w500,
      fontSize: widget.sourceFs,
      fontFamily: 'Beiruti',
      fontStyle: FontStyle.italic,
      height: 1.35,
    );

    final showN = _nMax > 0;
    final showBody = !showN || _stage >= 1;
    final showS = _sMax > 0 && _stage >= 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showN)
          _typedLine(
            full: _narrator,
            visible: _nLen,
            style: ctxStyle,
            caretHere: _stage == 0,
          ),
        if (showN && showBody && _tMax > 0) const SizedBox(height: 6),
        if (showBody && _tMax > 0)
          _typedLine(
            full: _text,
            visible: _tLen,
            style: bodyStyle,
            caretHere: _stage == 1,
          ),
        if (showS) ...[
          const SizedBox(height: 8),
          _typedLine(
            full: _source,
            visible: _sLen,
            style: srcStyle,
            caretHere: _stage == 2,
          ),
        ],
      ],
    );
  }
}
