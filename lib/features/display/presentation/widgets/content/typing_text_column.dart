import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/enums/app_numeral_format.dart';
import '../../../../../core/utils/app_number_format.dart';
import '../../../../../core/utils/app_font_loader.dart';
import '../../../../../data/models/design/design_settings_model.dart';
import '../../../../../data/models/mosque/mosque_text_entry_model.dart';

/// Displays a spiritual content entry (hadith, verse, dua, adhkar) as a
/// single-line horizontal marquee.
///
/// The full text (narrator — body  source) is shown immediately with a
/// fade-in, then scrolled horizontally at a comfortable pace.
///
/// - Text that fits the available width: shown statically (no scroll).
/// - Text that overflows: pauses 0.9 s then scrolls at [50, 150] px/s,
///   targeting completion within 13 s of the rotation window.
///
/// Scroll direction respects text direction:
/// - RTL (Arabic): beginning visible first (right), scrolls to reveal end.
/// - LTR: beginning visible first (left), scrolls to reveal end.
class TypingTextColumn extends StatefulWidget {
  const TypingTextColumn({
    super.key,
    required this.item,
    required this.primaryColor,
    required this.contextFs,
    required this.bodyFs,
    required this.sourceFs,
    required this.design,
    this.scrollSpeed = 1.0,
  });

  final MosqueTextEntryModel item;
  final Color primaryColor;
  final double contextFs;
  final double bodyFs;
  final double sourceFs;
  final DesignSettingsModel design;
  /// Multiplier applied to the scroll speed (1.0 = default, 2.0 = twice as fast).
  final double scrollSpeed;

  @override
  State<TypingTextColumn> createState() => _TypingTextColumnState();
}

class _TypingTextColumnState extends State<TypingTextColumn>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _scrollCtrl;

  // Cache to avoid re-measuring on every animation frame.
  double _textWidth = 0;
  double _containerWidth = 0;
  String _setupKey = '';
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _scrollCtrl = AnimationController(vsync: this)..addListener(_onTick);
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant TypingTextColumn old) {
    super.didUpdateWidget(old);
    if (old.item.id != widget.item.id ||
        old.item.text != widget.item.text ||
        old.scrollSpeed != widget.scrollSpeed) {
      _scrollTimer?.cancel();
      _setupKey = '';
      _fadeCtrl.reset();
      _fadeCtrl.forward();
      _scrollCtrl.stop();
      _scrollCtrl.reset();
    }
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _fadeCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  /// Measures [span] and schedules the scroll animation when text overflows.
  /// Guarded by [_setupKey]: runs only once per (item × containerWidth).
  void _trySetup(TextSpan span, double containerW, TextDirection dir) {
    final key = '${widget.item.id}|${containerW.round()}|${widget.scrollSpeed}';
    if (key == _setupKey) return;
    _setupKey = key;

    _scrollTimer?.cancel();
    _scrollCtrl.stop();
    _scrollCtrl.reset();

    final painter = TextPainter(text: span, textDirection: dir, maxLines: 1)
      ..layout(minWidth: 0, maxWidth: double.infinity);

    _textWidth = painter.width;
    _containerWidth = containerW;

    final overflow = _textWidth - _containerWidth;
    if (overflow <= 0) return; // Text fits — no scrolling needed.

    // Adaptive base speed: aim to finish in ~13 s, clamped to [50, 150] px/s.
    // Multiplied by scrollSpeed so the user setting scales the result linearly.
    final baseSpeed = (overflow / 13.0).clamp(50.0, 150.0);
    final speed = (baseSpeed * widget.scrollSpeed).clamp(20.0, 400.0);
    _scrollCtrl.duration = Duration(
      milliseconds: (overflow / speed * 1000).round(),
    );

    // Pause so the viewer can read the visible start, then scroll.
    final capturedKey = key;
    _scrollTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted && _setupKey == capturedKey) {
        _scrollCtrl.forward();
      }
    });
  }

  /// Horizontal translation for the current scroll position.
  ///
  /// RTL: −overflow → 0  (beginning [right] visible first → end [left] last)
  /// LTR:  0 → −overflow  (beginning [left] visible first → end [right] last)
  double _dx(TextDirection dir) {
    final overflow = _textWidth - _containerWidth;
    if (overflow <= 0) return 0;
    final t = _scrollCtrl.value;
    return dir == TextDirection.rtl ? -overflow * (1.0 - t) : -overflow * t;
  }

  TextSpan _buildSpan({
    required TextStyle ctxStyle,
    required TextStyle bodyStyle,
    required TextStyle srcStyle,
    required AppNumeralFormat fmt,
  }) {
    final narrator = widget.item.narrator.trim().formatNumerals(fmt);
    final body = widget.item.text.formatNumerals(fmt);
    final source = widget.item.source.trim().formatNumerals(fmt);

    final spans = <InlineSpan>[];
    if (narrator.isNotEmpty) {
      spans.add(TextSpan(text: narrator, style: ctxStyle));
      if (body.isNotEmpty) {
        spans.add(TextSpan(text: ' — ', style: ctxStyle));
      }
    }
    if (body.isNotEmpty) {
      spans.add(TextSpan(text: body, style: bodyStyle));
    }
    if (source.isNotEmpty) {
      spans.add(TextSpan(text: '  ', style: srcStyle));
      spans.add(TextSpan(text: source, style: srcStyle));
    }
    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.primaryColor;
    final fontFamily = widget.design.fontFamily;
    final fmt = widget.design.numeralFormat;
    final dir = Directionality.of(context);

    final ctxStyle = AppFontLoader.getStyle(
      fontFamily,
      baseStyle: TextStyle(
        color: p.withValues(alpha: 0.78),
        fontWeight: FontWeight.w600,
        fontSize: widget.contextFs,
        height: 1.35,
      ),
    );
    final bodyStyle = AppFontLoader.getStyle(
      fontFamily,
      baseStyle: TextStyle(
        color: p.withValues(alpha: 0.96),
        fontWeight: FontWeight.w700,
        fontSize: widget.bodyFs,
        height: 1.5,
        letterSpacing: 0.12,
      ),
    );
    final srcStyle = AppFontLoader.getStyle(
      fontFamily,
      baseStyle: TextStyle(
        color: p.withValues(alpha: 0.58),
        fontWeight: FontWeight.w500,
        fontSize: widget.sourceFs,
        fontStyle: FontStyle.italic,
        height: 1.35,
      ),
    );

    final span = _buildSpan(
      ctxStyle: ctxStyle,
      bodyStyle: bodyStyle,
      srcStyle: srcStyle,
      fmt: fmt,
    );

    return LayoutBuilder(
      builder: (ctx, constraints) {
        // Schedule measurement after the frame — never during build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _trySetup(span, constraints.maxWidth, dir);
        });

        return FadeTransition(
          opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
          child: ClipRect(
            child: Transform.translate(
              offset: Offset(_dx(dir), 0),
              child: RichText(
                text: span,
                textDirection: dir,
                maxLines: 1,
                softWrap: false,
                // ClipRect above handles clipping; visible here is intentional.
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        );
      },
    );
  }
}
