import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../enums/feedback/snackbar_type.dart';
import '../../utils/color_extensions.dart';
import '../../utils/responsive_layout.dart';
import 'snackbar_palette.dart';

/// The visual body of a toast — a frosted-glass card.
///
/// Design: a translucent ivory panel sitting on a real backdrop blur, lit by a
/// soft accent glow. The hero is a gradient icon chip that casts its own
/// coloured shadow. A slim gradient rail marks the start edge and a thin
/// countdown hairline depletes along the bottom over [duration]. Corners are
/// clipped so the blur, rail, and progress bar all follow the rounded shape.
class SnackbarContent extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final bool showCloseButton;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final VoidCallback? onClose;

  /// Visible lifetime of the toast — drives the countdown hairline.
  final Duration duration;

  const SnackbarContent({
    super.key,
    required this.message,
    required this.type,
    required this.showCloseButton,
    required this.duration,
    this.actionLabel,
    this.onActionTap,
    this.onClose,
  });

  @override
  State<SnackbarContent> createState() => _SnackbarContentState();
}

class _SnackbarContentState extends State<SnackbarContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;

  static const double _radius = 18;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(
      vsync: this,
      duration: widget.duration.inMilliseconds > 0
          ? widget.duration
          : const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  SnackbarPalette get _palette => SnackbarPalette.forType(widget.type);

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final accent = palette.accent;
    final accentLight = Color.lerp(accent, Colors.white, 0.28)!;

    return DecoratedBox(
      // Outer layer carries the shadows (kept outside the clip so the glow
      // is visible around the glass).
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacityCompat(0.28),
            blurRadius: 30,
            offset: const Offset(0, 14),
            spreadRadius: -8,
          ),
          BoxShadow(
            color: Colors.black.withOpacityCompat(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_radius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacityCompat(0.82),
                  SnackbarPalette.surface.withOpacityCompat(0.66),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacityCompat(0.55),
                width: 1,
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Slim gradient rail on the start edge (right in RTL).
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [accentLight, accent],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
                          child: Row(
                            children: [
                              _iconChip(context, accent, accentLight,
                                  palette.icon),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Text(
                                  widget.message,
                                  style: TextStyle(
                                    fontSize: context.adaptiveFont(13.5),
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                    color: SnackbarPalette.text,
                                  ),
                                ),
                              ),
                              if (widget.actionLabel != null &&
                                  widget.onActionTap != null) ...[
                                const SizedBox(width: 10),
                                _actionButton(context, accent, accentLight),
                              ],
                              if (widget.showCloseButton) ...[
                                const SizedBox(width: 6),
                                _closeButton(context),
                              ],
                            ],
                          ),
                        ),
                        _progressBar(accent, accentLight),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconChip(
    BuildContext context,
    Color accent,
    Color accentLight,
    IconData icon,
  ) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentLight, accent],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacityCompat(0.40),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Icon(icon, size: context.adaptiveIcon(20), color: Colors.white),
    );
  }

  Widget _actionButton(BuildContext context, Color accent, Color accentLight) {
    return GestureDetector(
      onTap: widget.onActionTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [accentLight, accent]),
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacityCompat(0.32),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          widget.actionLabel!,
          style: TextStyle(
            fontSize: context.adaptiveFont(11.5),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _closeButton(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose ??
          () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: SnackbarPalette.text.withOpacityCompat(0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.close_rounded,
          size: context.adaptiveIcon(14),
          color: SnackbarPalette.text.withOpacityCompat(0.55),
        ),
      ),
    );
  }

  /// Thin countdown hairline along the bottom edge: a faint track with an
  /// accent gradient bar that shrinks from full width to zero over [duration].
  Widget _progressBar(Color accent, Color accentLight) {
    return Container(
      height: 3,
      color: accent.withOpacityCompat(0.10),
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, _) {
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: (1.0 - _progress.value).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accentLight, accent]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
