import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/utils/app_number_format.dart';
import '../../../../data/models/design_settings_model.dart';
import '../../../../data/models/mosque_text_entry_model.dart';

/// Counts grapheme clusters (visible characters, important for Arabic).
int graphemeLength(String s) => Characters(s).length;

/// Returns the first [count] grapheme clusters from [s].
String graphemePrefix(String s, int count) {
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

/// Typing-animation text column: reveals narrator, body, and source
/// character-by-character with a blinking cursor.
class TypingTextColumn extends StatefulWidget {
  const TypingTextColumn({
    super.key,
    required this.item,
    required this.primaryColor,
    required this.contextFs,
    required this.bodyFs,
    required this.sourceFs,
    required this.design,
  });

  final MosqueTextEntryModel item;
  final Color primaryColor;
  final double contextFs;
  final double bodyFs;
  final double sourceFs;
  final DesignSettingsModel design;

  @override
  State<TypingTextColumn> createState() => _TypingTextColumnState();
}

class _TypingTextColumnState extends State<TypingTextColumn> {
  static const _tick = Duration(milliseconds: 26);

  Timer? _typeTimer;
  Timer? _caretTimer;

  late String _narrator;
  late String _text;
  late String _source;
  int _nLen = 0;
  int _tLen = 0;
  int _sLen = 0;

  /// 0 = narrator, 1 = body text, 2 = source, 3 = done
  int _stage = 0;
  bool _caretVisible = true;

  int get _nMax => graphemeLength(_narrator);
  int get _tMax => graphemeLength(_text);
  int get _sMax => graphemeLength(_source);
  bool get _typingDone => _stage >= 3;

  @override
  void initState() {
    super.initState();
    _initStrings();
    _startCaretBlink();
    _startTyping();
  }

  @override
  void didUpdateWidget(covariant TypingTextColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.text != widget.item.text ||
        oldWidget.design.numeralFormat != widget.design.numeralFormat) {
      _typeTimer?.cancel();
      _initStrings();
      _startTyping();
    }
  }

  void _initStrings() {
    final fmt = widget.design.numeralFormat;
    _narrator = widget.item.narrator.trim().formatNumerals(fmt);
    _text = widget.item.text.formatNumerals(fmt);
    _source = widget.item.source.trim().formatNumerals(fmt);
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
    int? maxLines,
    TextAlign textAlign = TextAlign.start,
  }) {
    final prefix = graphemePrefix(full, visible);
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
      textAlign: textAlign,
      maxLines: maxLines ?? 8,
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
      height: 1.35,
    );
    final bodyStyle = TextStyle(
      color: p.withValues(alpha: 0.96),
      fontWeight: FontWeight.w700,
      fontSize: widget.bodyFs,
      height: 1.5, // Balanced height
      letterSpacing: 0.12,
    );
    final srcStyle = TextStyle(
      color: p.withValues(alpha: 0.58),
      fontWeight: FontWeight.w500,
      fontSize: widget.sourceFs,
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
            maxLines: 2,
          ),
        if (showN && showBody && _tMax > 0) const SizedBox(height: 8),
        if (showBody && _tMax > 0)
          _typedLine(
            full: _text,
            visible: _tLen,
            style: bodyStyle,
            caretHere: _stage == 1,
            maxLines: 3, // Slightly reduced from 12
          ),
        if (showS) ...[
          const SizedBox(height: 10),
          _typedLine(
            full: _source,
            visible: _sLen,
            style: srcStyle,
            caretHere: _stage == 2,
            maxLines: 2,
          ),
        ],
      ],
    );
  }
}
