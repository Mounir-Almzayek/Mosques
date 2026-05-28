import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/platform_announcements/settings_announcement_model.dart';

class SettingsAnnouncementsSlider extends StatefulWidget {
  const SettingsAnnouncementsSlider({super.key, required this.announcements});

  final List<SettingsAnnouncementModel> announcements;

  @override
  State<SettingsAnnouncementsSlider> createState() =>
      _SettingsAnnouncementsSliderState();
}

class _SettingsAnnouncementsSliderState
    extends State<SettingsAnnouncementsSlider> {
  late final PageController _controller;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant SettingsAnnouncementsSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.announcements.length != widget.announcements.length) {
      _index = 0;
      if (_controller.hasClients) {
        _controller.jumpToPage(0);
      }
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.announcements.length < 2) return;

    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % widget.announcements.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.announcements.isEmpty) return const SizedBox.shrink();

    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: s.settings_app_announcements_title,
      child: Container(
        height: 178,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: widget.announcements.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  return _SettingsAnnouncementSlide(
                    announcement: widget.announcements[index],
                  );
                },
              ),
              PositionedDirectional(
                start: 16,
                end: 16,
                top: 14,
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.settings_app_announcements_title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.announcements.length > 1)
                PositionedDirectional(
                  end: 16,
                  bottom: 14,
                  child: _SliderDots(
                    count: widget.announcements.length,
                    currentIndex: _index,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsAnnouncementSlide extends StatelessWidget {
  const _SettingsAnnouncementSlide({required this.announcement});

  final SettingsAnnouncementModel announcement;

  Future<void> _openLink(BuildContext context) async {
    final raw = announcement.linkUrl?.trim();
    if (raw == null || raw.isEmpty) return;
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    if (uri.scheme != 'http' && uri.scheme != 'https') return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Ignore: opening links is best-effort.
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final hasImage = announcement.hasImage;
    final hasLink = announcement.hasLink;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final denseLayout = textScale > 1.1;
    final titleMaxLines = denseLayout && (hasImage || announcement.hasBody)
        ? 1
        : 2;
    final bodyMaxLines = denseLayout ? 1 : 2;
    final topPadding = denseLayout ? 40.0 : 46.0;

    final content = Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                scheme.primary,
                Color.lerp(scheme.primary, scheme.secondary, 0.45)!,
                scheme.tertiary.withValues(alpha: 0.92),
              ],
            ),
          ),
        ),
        if (hasImage)
          Positioned.fill(
            child: Image.network(
              announcement.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                colors: [
                  Colors.black.withValues(alpha: hasImage ? 0.68 : 0.32),
                  Colors.black.withValues(alpha: hasImage ? 0.34 : 0.12),
                  Colors.black.withValues(alpha: hasImage ? 0.08 : 0.04),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(18, topPadding, 18, 20),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasImage) ...[
                    _ImageBadge(
                      label: s.settings_app_announcements_image_badge,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    announcement.title.isNotEmpty
                        ? announcement.title
                        : s.settings_app_announcements_subtitle,
                    maxLines: titleMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                  if (announcement.hasBody) ...[
                    const SizedBox(height: 8),
                    Text(
                      announcement.body!,
                      maxLines: bodyMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (!hasLink) return content;

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openLink(context),
        child: content,
      ),
    );
  }
}

class _ImageBadge extends StatelessWidget {
  const _ImageBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_outlined, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderDots extends StatelessWidget {
  const _SliderDots({required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final selected = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsetsDirectional.only(start: 5),
          width: selected ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: selected ? 0.95 : 0.42),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
